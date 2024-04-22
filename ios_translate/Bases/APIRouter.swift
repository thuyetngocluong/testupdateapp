//
//  APIRouter.swift
//  ios_translate
//
//  Created by ThuyetLN on 19/4/24.
//


import AppKit
import Alamofire
import PromiseKit

public
struct APIRouterCommon {
    
    public
    enum AuthorizationType {
        case bearer(token: String)
        case noAuth
    }
    
    static func validateStatusCode(_ response: DataResponse<Any, AFError>) throws {
        guard let statusCode = response.response?.statusCode else { return }
        if statusCode != 401 && statusCode != 403 { return }
        
        throw BaseError.serverError(message: "Server Unauthenticated")
    }
    
    public
    static func createHeader(
        authorizationType   : AuthorizationType,
        isMultipartFromData : Bool = false
    )
    -> HTTPHeaders {
        
        var requestHeader = HTTPHeaders()
        
        requestHeader["Accept"] = "application/json"
        
        switch authorizationType{
        case .noAuth:
            break
        case .bearer(let token):
            requestHeader["Authorization"] = "Bearer " + token
        }
        
        if isMultipartFromData {
            requestHeader["Content-Type"]    = "multipart/form-data"
            requestHeader["Accept-Encoding"] = "gzip, deflate, br"
        }
        
        return requestHeader
    }
}

public enum ContentType {
    case json
    case fromUrlEncoder
    case xml
}

public protocol APIRouter {
    func baseURL() -> String
    func path() -> String?
    func headerParams() -> [String: String]
    func method() -> Alamofire.HTTPMethod
    func body() -> Alamofire.Parameters
    func params() -> Alamofire.Parameters
    func contentType() -> ContentType
}

public extension APIRouter {
    
    func body() -> Alamofire.Parameters { [:] }
    func params() -> Alamofire.Parameters { [:] }
    
    func contentType() -> ContentType {
        .fromUrlEncoder
    }
    
    func headerParams() -> [String: String] {
        [:]
    }
    func headers() -> Alamofire.HTTPHeaders {
        .init(params: headerParams())
    }
    
    func asURLRequest() -> URLRequest {
        
        var url = URL(string: baseURL())!
        
        if let path = path() {
            url = url.appendingPathComponent(path)
        }
        var urlRequest: URLRequest = URLRequest(url: url)
        urlRequest.httpMethod = method().rawValue
        
        // setting header
        for (key, value) in headers().dictionary {
            urlRequest.addValue(value, forHTTPHeaderField: key)
        }
        
        let body = body()
        
        do {
            urlRequest = try URLEncoding(destination: .queryString).encode(urlRequest, with: params())
            if !body.isEmpty {
                if method() == .post || method() == .put {
                    switch contentType() {
                    case .fromUrlEncoder:
                        urlRequest = try URLEncoding(destination: .httpBody).encode(urlRequest, with: body)
                    case .json:
                        urlRequest = try JSONEncoding().encode(urlRequest, with: body)
                    case .xml:
                        urlRequest.httpBody = (body["xml"] as? String)?.data(using: .utf8, allowLossyConversion: true)
                    }
                }
            }
            
            
        } catch {
            print("Encoding fail")
        }
        return urlRequest
    }
    
    func doRequest<T: Decodable>(session: Session = .default, responseDecodedTo type: T.Type) async -> T? {
        return await withCheckedContinuation { continuation in
            let request = asURLRequest()
            session
                .request(request)
                .cURLDescription {
                    print("CURL ", $0)
                }
                .validate(statusCode: 200..<300)
                .responseDecodable(of: T.self) { response in
                    switch response.result {
                    case .success(let value):
                        continuation.resume(returning: value)
                    case .failure(let error):
                        print("LNT", error.localizedDescription)
                        continuation.resume(returning: nil)
                    }
                }
        }
    }
    
    func doRequestToResponseData(session: Session = .default) async -> AFDataResponse<Data> {
        return await withCheckedContinuation { continuation in
            let request = asURLRequest()
            session
                .request(request)
                .cURLDescription {
                    print("CURL ", $0)
                }
                .responseData { response in
                    continuation.resume(returning: response)
                }
        }
    }
    
    @discardableResult
    func doRequestToData(session: Session = .default,
                         middleware: ((AFDataResponse<Data>) -> AFDataResponse<Data>)? = nil) async -> Data? {
        return await withCheckedContinuation { continuation in
            let request = asURLRequest()
            session
                .request(request)
                .cURLDescription {
                    print("CURL ", $0)
                }
                .responseData { response in
                    let response = middleware?(response) ?? response
                    if let statusCode = response.response?.statusCode,
                       (400...500).contains(statusCode)
                    {
                        continuation.resume(returning: nil)
                        return;
                    }
                    switch response.result {
                    case .success(let value):
                        continuation.resume(returning: value)
                    case .failure(let error):
                        print(error.localizedDescription)
                        continuation.resume(returning: nil)
                    }
                }
        }
    }
    
    func call(session: Session = .default, responseData: @escaping (AFDataResponse<Data?>) -> Void) {
        let request = asURLRequest()
        session
            .request(request)
            .cURLDescription {
                print("CURL ", $0)
            }
            .response { result in
                responseData(result)
            }
    }
}

public extension HTTPHeaders {
    init(params: [String: String]) {
        var headers = HTTPHeaders.init()
        for (key, value) in params {
            headers.add(name: key, value: value)
        }
        self = headers
    }
}
