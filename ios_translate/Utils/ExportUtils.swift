//
//  ExportUtils.swift
//  ios_translate
//
//  Created by ThuyetLN on 23/4/24.
//

import Foundation
import AppKit
import Zip


private extension LanguageItem {
    var folderName: String {
        if let countryCode {
            return "\(language.languageCode)-\(countryCode).lproj"
        }
        return "\(language.languageCode).lproj"
    }
}

struct ExportUtils {
    static let shared = ExportUtils()
    
    func exportToZip(translations: [Translation] = AppDataManager.shared.translations, languages: [LanguageItem] = AppDataManager.shared.selectedApplication.languages) {
        let folderURL = FileManager.default.temporaryDirectory.appendingPathComponent("zip", isDirectory: true)
        try? FileManager.default.removeItem(at: folderURL)
        try? FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
        
        for language in languages {
            let languageFolder = folderURL.appendingPathComponent(language.folderName, isDirectory: true)
            try? FileManager.default.createDirectory(at: languageFolder, withIntermediateDirectories: true)
            
            let stringFile = languageFolder.appendingPathComponent("Localizable.strings")
            
            let data = translations.map { translation in
                let key = translation.key
                let value = translation.translates.first(where: { $0.language == language })?.value ?? ""
                return "\"\(key)\" = \(value.jsonStringfy());"
            }.joined(separator: "\n").data(using: .utf8)
            
            guard let data = data else { continue }
            try? data.write(to: stringFile)
        }
        do {
            let archive = try Zip.quickZipFiles([folderURL], fileName: "result.zip")
            DispatchQueue.main.async {
                let savePanel = NSSavePanel()
                savePanel.canCreateDirectories = true
                savePanel.allowedContentTypes = [.zip]
                savePanel.title = "Save"
                savePanel.begin { [weak savePanel] result in
                    guard let url = savePanel?.url,
                          result == .OK else { return }
                    do {
                        let data = try Data(contentsOf: archive)
                        try data.write(to: url)
                    } catch {
                        print("ERROR")
                    }
                }
            }
        } catch {
            
        }
    }
    
    func replaceZip(translations: [Translation] = AppDataManager.shared.translations, languages: [LanguageItem] = AppDataManager.shared.selectedApplication.languages) {
        var resultZip: [LanguageItem: Data] = [:]
        for language in languages {
            
            
            
            let data = translations.map { translation in
                let key = translation.key
                let value = translation.translates.first(where: { $0.language == language })?.value ?? ""
                return "\"\(key)\" = \(value.jsonStringfy());"
            }.joined(separator: "\n").data(using: .utf8)
            
            guard let data = data else { continue }
            resultZip[language] = data
        }
        do {
            DispatchQueue.main.async {
                let savePanel = NSOpenPanel()
                savePanel.canCreateDirectories = true
                savePanel.canChooseDirectories = true
                savePanel.title = "Save"
                savePanel.begin { [weak savePanel] result in
                    guard let url = savePanel?.url,
                          result == .OK else { return }
                    do {
                        for (language, aResultZip) in resultZip {
                            let folder = url.appendingPathComponent("\(language.languageAndCountryCode).lproj",
                                                                    isDirectory: true)
                            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
                            try? aResultZip.write(to: folder.appendingPathComponent("Localizable.strings"))
                        }
                    } catch {
                        print("ERROR")
                    }
                }
            }
        } catch {
            
        }
    }
    
    
    func exportToStringCatalogs(translations: [Translation] = AppDataManager.shared.translations, languages: [LanguageItem] = AppDataManager.shared.selectedApplication.languages) {
        var result: [String: Any] = [
            "sourceLanguage": "en",
            "version": "1.0"
        ]
        
        var strings: [String: Any] = [:]
        for translation in translations {
            var itemTranslation: [String: Any] = [
                "extractionState": "manual",
            ]
            var localizations: [String: [String: [String: String]]] = [:]
            for translate in translation.translates {
                guard languages.contains(translate.language) else { continue }
                localizations[translate.language.languageAndCountryCode] = [
                    "stringUnit": [
                        "state": "translated",
                        "value": translate.value
                    ]
                ]
                
            }
            itemTranslation["localizations"] = localizations
            
            strings[translation.key] = itemTranslation
        }
        
        result["strings"] = strings
        
        DispatchQueue.main.async {
            let savePanel = NSSavePanel()
            savePanel.canCreateDirectories = true
            savePanel.nameFieldStringValue = "Localizable.xcstrings"
//            savePanel.allowedContentTypes = []
            savePanel.title = "Save"
            savePanel.begin { [weak savePanel] rs in
                    guard let url = savePanel?.url,
                          rs == .OK
                    else { return }
                DispatchQueue.global().async {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                        try jsonData.write(to: url)
                    } catch {
                        print("ERROR")
                    }
                }
            }
        }
    }
}
