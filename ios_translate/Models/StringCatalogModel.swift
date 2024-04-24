//
//  StringCatalogModel.swift
//  ios_translate
//
//  Created by ThuyetLN on 23/4/24.
//

import Foundation
import EasyCodable


struct StringCatalogModel: Codable {
    var sourceLanguage: String = ""
    var version: String = ""
    var strings: [String: KeyData] = [:]
    
    init(from decoder: any Decoder) throws {
        let container: KeyedDecodingContainer<StringCatalogModel.CodingKeys> = try decoder.container(keyedBy: StringCatalogModel.CodingKeys.self)
        self.sourceLanguage <- container[.sourceLanguage]
        self.version <- container[.version]
        self.strings <- container[.strings]
    }
}

extension StringCatalogModel {
    struct KeyData: Codable {
        var extractionState: String = ""
        var localizations: [String: StringUnitContainer] = [:]
        
        init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<StringCatalogModel.KeyData.CodingKeys> = try decoder.container(keyedBy: StringCatalogModel.KeyData.CodingKeys.self)
            self.extractionState <- container[.extractionState]
            self.localizations <- container[.localizations]
        }
    }
    struct StringUnitContainer: Codable {
        var stringUnit: StringUnit = .init()
    }
    struct StringUnit: Codable {
        var state: String = ""
        var value: String = ""
        
        init() {}
        
        init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<StringCatalogModel.StringUnit.CodingKeys> = try decoder.container(keyedBy: StringCatalogModel.StringUnit.CodingKeys.self)
            self.state <- container[.state]
            self.value <- container[.value]
        }
    }
    
    
}
