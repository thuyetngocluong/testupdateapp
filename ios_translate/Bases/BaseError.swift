//
//  BaseError.swift
//  ios_translate
//
//  Created by ThuyetLN on 19/4/24.
//

import Foundation


enum BaseError: LocalizedError {
    
    case localError(message: String)
    case serverError(message: String)
    
    public
    var errorDescription: String? {
        switch self {
        case .localError(let message),
                .serverError(let message):
            return message
        }
    }
}
