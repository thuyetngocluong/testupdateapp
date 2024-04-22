//
//  Language.swift
//  ios_translate
//
//  Created by ThuyetLN on 19/4/24.
//

import Foundation
import EasyCodable
import Then

struct LanguageItem: Hashable, Codable, Then {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    var id: Int = -1
    var language: Language = .english
    var languageName: String = ""
    var countryCode: String?
    
    enum CodingKeys: String, CodingKey {
        case id             = "id"
        case language       = "language_code"
        case languageName   = "language_name"
        case countryCode    = "country_code"
    }
    
    init() {}
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id <- container[.id]
        self.language <- container[.language]
        self.languageName <- container[.languageName]
        self.countryCode <- container[.countryCode]
    }
    
    var languageHashable: String {
        if let countryCode = countryCode {
            return "\(language.languageCode)-\(countryCode)"
        }
        return language.languageCode
    }
    
    var languageText: String {
        if let countryCode = countryCode {
            return "\(language.rawValue) (\(language.languageCode)-\(countryCode))"
        }
        return language.rawValue
    }
}

enum Language: String, CaseIterable, Codable {
    case ainu
    case albanian
    case amharic
    case apacheWestern
    case arabic
    case armenian
    case assamese
    case assyrian
    case azerbaijani
    case bangla
    case belarusian
    case bodo
    case bulgarian
    case burmese
    case cantonese
    case catalan
    case cherokee
    case chinese
    case croatian
    case czech
    case danish
    case dhivehi
    case dogri
    case dutch
    case dzongkha
    case english
    case estonian
    case faroese
    case finnish
    case french
    case fula
    case georgian
    case german
    case greek
    case gujarati
    case hawaiian
    case hebrew
    case hindi
    case hungarian
    case icelandic
    case igbo
    case indonesian
    case irish
    case italian
    case japanese
    case kannada
    case kashmiri
    case kazakh
    case khmer
    case konkani
    case korean
    case kurdish
    case kurdishSorani
    case kyrgyz
    case lao
    case latvian
    case lithuanian
    case macedonian
    case maithili
    case malay
    case malayalam
    case maltese
    case manipuri
    case māori
    case marathi
    case mongolian
    case navajo
    case nepali
    case norwegian
    case norwegianBokmål
    case norwegianNynorsk
    case odia
    case pashto
    case persian
    case polish
    case portuguese
    case punjabi
    case rohingya
    case romanian
    case russian
    case samoan
    case sanskrit
    case santali
    case serbian
    case sindhi
    case sinhala
    case slovak
    case slovenian
    case spanish
    case swahili
    case swedish
    case tagalog
    case tajik
    case tamil
    case telugu
    case thai
    case tibetan
    case tongan
    case turkish
    case turkmen
    case ukrainian
    case urdu
    case uyghur
    case uzbek
    case vietnamese
    case welsh
    case yiddish
    
    init?(languageCode: String) {
        if let exist = Language.allCases.first(where: { $0.languageCode == languageCode }) {
            self = exist
        } else {
            return nil
        }
    }
    
    init(from decoder: any Decoder) throws {
        
        let languageCode: String? = (try? decoder.singleValueContainer().decode(String.self))
        ?? (try? decoder.singleValueContainer().decode(LanguageResponse.self).language_code)
        if let languageCode = languageCode,
           let raw = Language(languageCode: languageCode) {
            self = raw
        } else {
            throw BaseError.localError(message: "")
        }
    }
    
    var languageCode: String {
        switch self {
        case .ainu:
            return "ain"
        case .albanian:
            return "sq"
        case .amharic:
            return "am"
        case .apacheWestern:
            return "apw"
        case .arabic:
            return "ar"
        case .armenian:
            return "hy"
        case .assamese:
            return "as"
        case .assyrian:
            return "syr"
        case .azerbaijani:
            return "az"
        case .bangla:
            return "bn"
        case .belarusian:
            return "be"
        case .bodo:
            return "brx"
        case .bulgarian:
            return "bg"
        case .burmese:
            return "my"
        case .cantonese:
            return "yue"
        case .catalan:
            return "ca"
        case .cherokee:
            return "chr"
        case .chinese:
            return "zh"
        case .croatian:
            return "hr"
        case .czech:
            return "cs"
        case .danish:
            return "da"
        case .dhivehi:
            return "dv"
        case .dogri:
            return "doi"
        case .dutch:
            return "nl"
        case .dzongkha:
            return "dz"
        case .english:
            return "en"
        case .estonian:
            return "et"
        case .faroese:
            return "fo"
        case .finnish:
            return "fi"
        case .french:
            return "fr"
        case .fula:
            return "ff"
        case .georgian:
            return "ka"
        case .german:
            return "de"
        case .greek:
            return "el"
        case .gujarati:
            return "gu"
        case .hawaiian:
            return "haw"
        case .hebrew:
            return "he"
        case .hindi:
            return "hi"
        case .hungarian:
            return "hu"
        case .icelandic:
            return "is"
        case .igbo:
            return "ig"
        case .indonesian:
            return "id"
        case .irish:
            return "ga"
        case .italian:
            return "it"
        case .japanese:
            return "ja"
        case .kannada:
            return "kn"
        case .kashmiri:
            return "ks"
        case .kazakh:
            return "kk"
        case .khmer:
            return "km"
        case .konkani:
            return "kok"
        case .korean:
            return "ko"
        case .kurdish:
            return "ku"
        case .kurdishSorani:
            return "ckb"
        case .kyrgyz:
            return "ky"
        case .lao:
            return "lo"
        case .latvian:
            return "lv"
        case .lithuanian:
            return "lt"
        case .macedonian:
            return "mk"
        case .maithili:
            return "mai"
        case .malay:
            return "ms"
        case .malayalam:
            return "ml"
        case .maltese:
            return "mt"
        case .manipuri:
            return "mni"
        case .māori:
            return "mi"
        case .marathi:
            return "mr"
        case .mongolian:
            return "mn"
        case .navajo:
            return "nv"
        case .nepali:
            return "ne"
        case .norwegian:
            return "no"
        case .norwegianBokmål:
            return "nb"
        case .norwegianNynorsk:
            return "nn"
        case .odia:
            return "or"
        case .pashto:
            return "ps"
        case .persian:
            return "fa"
        case .polish:
            return "pl"
        case .portuguese:
            return "pt"
        case .punjabi:
            return "pa"
        case .rohingya:
            return "rhg"
        case .romanian:
            return "ro"
        case .russian:
            return "ru"
        case .samoan:
            return "sm"
        case .sanskrit:
            return "sa"
        case .santali:
            return "sat"
        case .serbian:
            return "sr"
        case .sindhi:
            return "sd"
        case .sinhala:
            return "si"
        case .slovak:
            return "sk"
        case .slovenian:
            return "sl"
        case .spanish:
            return "es"
        case .swahili:
            return "sw"
        case .swedish:
            return "sv"
        case .tagalog:
            return "tl"
        case .tajik:
            return "tg"
        case .tamil:
            return "ta"
        case .telugu:
            return "te"
        case .thai:
            return "th"
        case .tibetan:
            return "bo"
        case .tongan:
            return "to"
        case .turkish:
            return "tr"
        case .turkmen:
            return "tk"
        case .ukrainian:
            return "uk"
        case .urdu:
            return "ur"
        case .uyghur:
            return "ug"
        case .uzbek:
            return "uz"
        case .vietnamese:
            return "vi"
        case .welsh:
            return "cy"
        case .yiddish:
            return "yi"
        }
    }
    
    var countryCodes: [String] {
        switch self {
        case .ainu:
            return ["JP"]
        case .albanian:
            return ["AL", "XK", "MK"]
        case .amharic:
            return ["ET"]
        case .apacheWestern:
            return ["US"]
        case .arabic:
            return []
        case .armenian:
            return ["AM"]
        case .assamese:
            return ["IN"]
        case .assyrian:
            return ["IQ", "SY"]
        case .azerbaijani:
            return ["Cyrl", "Cyrl-AZ", "AZ"]
        case .bangla:
            return ["BD", "IN"]
        case .belarusian:
            return ["BY"]
        case .bodo:
            return ["IN"]
        case .bulgarian:
            return ["BG"]
        case .burmese:
            return ["MM"]
        case .cantonese:
            return ["Hans", "Hans-CN", "Hant", "Hant-HK"]
        case .catalan:
            return ["AD", "FR", "IT", "ES"]
        case .cherokee:
            return ["US"]
        case .chinese:
            return ["HK", "Hans", "Hans-CN", "Hans-HK", "Hans-JP", "Hans-MO", "Hans-SG", "Hant", "Hant-CN","Hant-HK", "Hant-JP", "Hant-MO", "Hant-TW"]
        case .croatian:
            return ["BA", "HR"]
        case .czech:
            return ["CZ"]
        case .danish:
            return ["DK", "GL"]
        case .dhivehi:
            return ["MV"]
        case .dogri:
            return ["IN"]
        case .dutch:
            return ["AW", "BE", "BQ", "CW", "NL", "SX", "SR"]
        case .dzongkha:
            return ["BT"]
        case .english:
            return []
        case .estonian:
            return ["EE"]
        case .faroese:
            return ["DK","FO"]
        case .finnish:
            return ["FI"]
        case .french:
            return [
                "DZ", "BE", "BJ", "BF", "BI", "CM", "CA", "CF", "TD", "KM", "CG", "CD", "CI", "DJ", "GQ", "FR", "GF", "PF", "GA", "GP",
                "GN", "HT", "LU", "MG", "ML", "MQ", "MR", "MU", "YT", "MC", "MA", "NC", "NE", "RE", "RW", "SN", "SC", "BL", "MF", "PM",
                "CH", "SY", "TG", "TN", "VU", "WF"
            ]
        case .fula:
            return []
        case .georgian:
            return []
        case .german:
            return []
        case .greek:
            return []
        case .gujarati:
            return []
        case .hawaiian:
            return []
        case .hebrew:
            return []
        case .hindi:
            return ["IN", "Latn", "Latn-IN"]
        case .hungarian:
            return []
        case .icelandic:
            return []
        case .igbo:
            return []
        case .indonesian:
            return ["ID"]
        case .irish:
            return []
        case .italian:
            return ["IT", "SM", "CH", "VA"]
        case .japanese:
            return []
        case .kannada:
            return []
        case .kashmiri:
            return []
        case .kazakh:
            return []
        case .khmer:
            return []
        case .konkani:
            return []
        case .korean:
            return []
        case .kurdish:
            return []
        case .kurdishSorani:
            return []
        case .kyrgyz:
            return []
        case .lao:
            return []
        case .latvian:
            return []
        case .lithuanian:
            return []
        case .macedonian:
            return []
        case .maithili:
            return []
        case .malay:
            return []
        case .malayalam:
            return []
        case .maltese:
            return []
        case .manipuri:
            return []
        case .māori:
            return []
        case .marathi:
            return []
        case .mongolian:
            return []
        case .navajo:
            return []
        case .nepali:
            return []
        case .norwegian:
            return []
        case .norwegianBokmål:
            return ["NO", "SJ"]
        case .norwegianNynorsk:
            return []
        case .odia:
            return []
        case .pashto:
            return []
        case .persian:
            return []
        case .polish:
            return []
        case .portuguese:
            return ["AO", "BR", "CV", "GQ", "FR", "GW", "LU", "MO", "MZ", "PT", "ST", "CH", "TL"]
        case .punjabi:
            return []
        case .rohingya:
            return []
        case .romanian:
            return []
        case .russian:
            return []
        case .samoan:
            return []
        case .sanskrit:
            return []
        case .santali:
            return []
        case .serbian:
            return []
        case .sindhi:
            return []
        case .sinhala:
            return []
        case .slovak:
            return []
        case .slovenian:
            return []
        case .spanish:
            return []
        case .swahili:
            return []
        case .swedish:
            return []
        case .tagalog:
            return []
        case .tajik:
            return []
        case .tamil:
            return []
        case .telugu:
            return []
        case .thai:
            return []
        case .tibetan:
            return []
        case .tongan:
            return []
        case .turkish:
            return []
        case .turkmen:
            return []
        case .ukrainian:
            return []
        case .urdu:
            return []
        case .uyghur:
            return []
        case .uzbek:
            return []
        case .vietnamese:
            return []
        case .welsh:
            return []
        case .yiddish:
            return []
        }
    }
}


extension Language {
    private struct LanguageResponse: Codable {
        var id: Int = -1
        var language_code: String = ""
        var language_name: String = ""
        
        init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<Language.LanguageResponse.CodingKeys> = try decoder.container(keyedBy: Language.LanguageResponse.CodingKeys.self)
            self.id <- container[.id]
            self.language_code <- container[.language_code]
            self.language_name <- container[.language_name]
        }
    }
}
