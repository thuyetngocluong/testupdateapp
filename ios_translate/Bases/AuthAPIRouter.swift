//
//  AuthAPIRouter.swift
//  ios_translate
//
//  Created by ThuyetLN on 19/4/24.
//

import Foundation
import Alamofire


enum AuthAPIRouter: APIRouter {
        
    case login(username: String, password: String)
    case checkMe
    case createLanguage(language: Language)
    case getTranslations(applicationID: Int)
    case updateLanguage(_ language: LanguageItem)
    case fetchLanguages
    case updatePreferredLanguage(applicationID: Int, languages: [LanguageItem])
    case updateTranslation(id: Int, key: String, translated: String, languageID: Int)
    case createNewTranslation(translation: Translation, applicationID: Int)
    
    func baseURL() -> String {
        return UserDefaults.standard.currentHost ?? "http://10.10.0.157:3006"
    }
    
    func path() -> String? {
        switch self {
        case .login:
            return "/api/auth/local"
        case .checkMe:
            return "/api/me"
        case .createLanguage:
            return "/api/langages"
        case .getTranslations:
            return "/api/translates-all"
        case .updateLanguage:
            return "/api/language/update"
        case .fetchLanguages:
            return "/api/language/all"
        case .updatePreferredLanguage:
            return "/api/application"
        case .updateTranslation:
            return "/api/update-key"
        case .createNewTranslation:
            return "/api/create-new-key"
        }
    }
    
    func headers() -> Alamofire.HTTPHeaders {
        .init()
    }
    
    func body() -> Alamofire.Parameters {
        switch self {
        case .login(let username, let password):
            return [
                "identifier": username,
                "password": password
            ]
        case .createLanguage(let language):
            return [
                "data": [
                    "language_code": language.languageCode,
                    "language_name": language.rawValue,
                    "country_codes": language.countryCodes.joined(separator: ", ")
                ]
            ]
        case .updateLanguage(let language):
            return [
                "data": [
                    "language_code": language.language.languageCode,
                    "language_name": language.language.rawValue,
                    "country_code": language.countryCode,
                ]
            ]
        case .updatePreferredLanguage(let applicationID, let languages):
            return [
                "languages": languages.map { language in
                    return [
                        "id": language.id
                    ]
                },
                "applicationID": applicationID
            ]
        case .updateTranslation(let id, let key, let translated, let languageID):
            return [
                "id": id,
                "key": key,
                "languageID": languageID,
                "translated": translated
            ]
            
        case .createNewTranslation(let translation, let applicationID):
            do {
                let translation = try JSONEncoder().encode(translation)
                guard var dictionary = try JSONSerialization.jsonObject(with: try JSONEncoder().encode(translation), options: []) as? [String: Any] else {
                    return [:]
                }
                dictionary.removeValue(forKey: "id")
                dictionary["application"] = applicationID
                return [
                    "data": dictionary
                ]
            } catch {
                return [:]
            }
        default:
            return [:]
        }
    }
    
    func params() -> Parameters {
        switch self {
        case .getTranslations(let applicationID):
            return [
                "applicationID": applicationID
            ]
        default:
            return [:]
        }
    }
    
    func method() -> Alamofire.HTTPMethod {
        switch self {
        case .login, .createLanguage, .updateTranslation:
            return .post
        case .checkMe, .getTranslations, .fetchLanguages, .createNewTranslation:
            return .get
        case .updateLanguage, .updatePreferredLanguage:
            return .put
        }
    }
    
    func contentType() -> ContentType {
        .json
    }
    
    func headerParams() -> [String : String] {
        switch self {
        case .login:
            return [:]
        default:
            return [
                "Authorization": "Bearer \(UserDefaults.standard.currentUserJWT ?? "")"
            ]
        }
    }
    
}
