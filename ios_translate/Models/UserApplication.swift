//
//  UserApplication.swift
//  ios_translate
//
//  Created by ThuyetLN on 19/4/24.
//

import Foundation
import EasyCodable

struct UserApplication: Codable, Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id: Int = -1
    var name: String = ""
    var languages: [LanguageItem] = []
    var defaultContext: String = ""
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case languages
        case defaultContext = "default_context"
    }
    
    init() {}
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id <- container[.id]
        self.name <- container[.name]
        self.languages <- container[.languages]
        self.defaultContext <- container[.defaultContext]
        
        self.languages.sort(by: { $0.languageText < $1.languageText })
    }
}
