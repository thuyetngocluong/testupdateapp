//
//  Translation.swift
//  ios_translate
//
//  Created by ThuyetLN on 20/4/24.
//

import Foundation
import EasyCodable


struct Translation: Codable {
    var id: Int = .zero
    var key: String = ""
    var translates: [Item] = []
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id <- container[.id]
        self.key <- container[.key]
        self.translates <- container[.translates]
    }
}


extension Translation {
    struct Item: Codable {
        var id: Int = .zero
        var value: String = ""
        var language: Language = .english
        
        init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<Translation.Item.CodingKeys> = try decoder.container(keyedBy: Translation.Item.CodingKeys.self)
            self.id <- container[.id]
            self.value <- container[.value]
            self.language <- container[.language]
        }
    }
}
