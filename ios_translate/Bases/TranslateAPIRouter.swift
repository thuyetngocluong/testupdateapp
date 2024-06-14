//
//  TranslateAPIRouter.swift
//  ios_translate
//
//  Created by ThuyetLN on 23/4/24.
//

import Alamofire
import Foundation


enum TranslateAPIRouter: APIRouter {
   
    case translate(text: String, context: String, languageCodes: [String])
    case translateTexts(texts: [String], context: String, languageCode: String)
    case importNewKey(translation: Translation)
    case deleteTranslation(translationID: Int)
    
    func baseURL() -> String {
        return UserDefaults.standard.currentHost ?? "http://10.10.0.157:3006"
    }
    
    func path() -> String? {
        switch self {
        case .translate:
            return "/api/translate-text"
        case .translateTexts:
            return "/api/translate-texts"
        case .importNewKey:
            return "/api/import-new-key"
        case .deleteTranslation:
            return "/api/delete-key"
        }
    }
    
    func headers() -> Alamofire.HTTPHeaders {
        .init()
    }
    
    func body() -> Alamofire.Parameters {
        switch self {
        case .translate(let text, let context, let languageCodes):
            return [
                "text": text,
                "context": context,
                "languageCodes": languageCodes
            ]
        case .importNewKey(let translation):
            return [
                "data": [
                    "key": translation.key,
                    "application": AppDataManager.shared.selectedApplication.id,
                    "translates": translation.translates.map { translate in
                        return [
                            "value": translate.value,
                            "language": translate.language.id
                        ]
                    }
                ]
            ]
            
        case .deleteTranslation(let translationID):
            return [
                "id": translationID
            ]
            
        case .translateTexts(let texts, let context, let languageCode):
            return [
                "texts": texts,
                "context": context,
                "languageCode": languageCode
            ]
            
        default:
            return [:]
        }
    }
    
    func method() -> Alamofire.HTTPMethod {
        .post
    }
    
    func contentType() -> ContentType {
        .json
    }
    
    func headerParams() -> [String : String] {
        return [
            "Authorization": "Bearer \(UserDefaults.standard.currentUserJWT ?? "")"
        ]
    }
}
