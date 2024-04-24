//
//  ImportUtils.swift
//  ios_translate
//
//  Created by ThuyetLN on 23/4/24.
//

import AppKit
import Zip


struct ImportUtils {
    static let shared = ImportUtils()
    
    func importFromStringCatalog(completion: (([Translation]) -> Void)?) {
        DispatchQueue.main.async {
            
            let pannel = NSOpenPanel()
            pannel.canChooseFiles = true
            pannel.canChooseDirectories = false
            pannel.title = "Open"
            pannel.begin { [weak pannel] result in
                guard let url = pannel?.url,
                      result == .OK else {
                    completion?([])
                    return
                }
                do {
                    let data = try Data(contentsOf: url)
                    let stringCatalog = try JSONDecoder().decode(StringCatalogModel.self, from: data)
                    
                    let languages = AppDataManager.shared.selectedApplication.languages
                    
                    let translations = stringCatalog.strings.map { (key, keyData) in
                        var translation = Translation()
                        translation.key = key
                        translation.translates = keyData.localizations.compactMap { (languageAndCountryCode, value) -> Translation.Item? in
                            guard let language = languages.first(where: { $0.languageAndCountryCode == languageAndCountryCode }) else {
                                return nil
                            }
                            var item = Translation.Item()
                            item.language = language
                            item.value = value.stringUnit.value
                            return item
                        }
                        return translation
                    }
                    
                    completion?(translations)
                } catch {
                    completion?([])
                    print("ERROR")
                }
            }
        }
    }
    
    
    func importFromZip(completion: (([Translation]) -> Void)?) {
        DispatchQueue.main.async {
            
            let pannel = NSOpenPanel()
            pannel.canChooseFiles = true
            pannel.canChooseDirectories = false
            pannel.allowedContentTypes = [.zip]
            pannel.title = "Open"
            pannel.begin { [weak pannel] result in
                guard let url = pannel?.url,
                      result == .OK else {
                    completion?([])
                    return
                }
                
                DispatchQueue.global().async {
                    do {
                        let languages = AppDataManager.shared.selectedApplication.languages
                        let zipURL = try Zip.quickUnzipFile(url)
                        let folders = enumarateProjFolderURL(url: zipURL)
                        var translations = [Translation]()
                        let regex = try NSRegularExpression(pattern: #"("([^"]+)"\s*=\s*"([^"]+)"\s*;)"#)
                        for folder in folders {
                            guard let language = languages.first(where: { folder.lastPathComponent.components(separatedBy: ".").first == $0.languageAndCountryCode }),
                                  let data = try? Data(contentsOf: folder.appendingPathComponent("Localizable.strings")),
                                  let string = String(data: data, encoding: .utf8)
                            else {
                                continue
                            }

                            let matches = regex.matches(in: string, range: NSRange(string.startIndex..<string.endIndex, in: string))
                            for match in matches {
                                let key = {
                                    let range = match.range(at: 2)
                                    if let swiftRange = Range(range, in: string) {
                                        let matchedString = string[swiftRange]
                                        return String(matchedString)
                                    }
                                    return ""
                                }()
                                
                                let value = {
                                    let range = match.range(at: 3)
                                    if let swiftRange = Range(range, in: string) {
                                        let matchedString = string[swiftRange]
                                        return String(matchedString)
                                    }
                                    return ""
                                }()
                                if value.isEmpty {
                                    print(key)
                                }
                                guard !key.isEmpty else {
                                    continue
                                }
                                
                                var item = Translation.Item()
                                item.language = language
                                item.value = String(value)
                                
                                if let idxTranslation = translations.firstIndex(where: { $0.key == key }) {
                                    translations[idxTranslation].translates.append(item)
                                } else {
                                    var new = Translation()
                                    new.key = key
                                    new.translates = [item]
                                    translations.append(new)
                                }
                                
                            }
                        }
                        completion?(translations)
                    } catch {
                        completion?([])
                    }
                }
                //                do {
                //                    let data = try Data(contentsOf: url)
                //                    let stringCatalog = try JSONDecoder().decode(StringCatalogModel.self, from: data)
                //
                //                    let languages = AppDataManager.shared.selectedApplication.languages
                //
                //                    let translations = stringCatalog.strings.map { (key, keyData) in
                //                        var translation = Translation()
                //                        translation.key = key
                //                        translation.translates = keyData.localizations.compactMap { (languageAndCountryCode, value) -> Translation.Item? in
                //                            guard let language = languages.first(where: { $0.languageAndCountryCode == languageAndCountryCode }) else {
                //                                return nil
                //                            }
                //                            var item = Translation.Item()
                //                            item.language = language
                //                            item.value = value.stringUnit.value
                //                            return item
                //                        }
                //                        return translation
                //                    }
                //
                //                    completion?(translations)
                //                } catch {
                //                    completion?([])
                //                    print("ERROR")
                //                }
            }
        }
    }
    
    private
    func enumarateProjFolderURL(url: URL) -> [URL] {
        var results: [URL] = []
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            for url in urls {
                if url.lastPathComponent.contains(".lproj") {
                    results.append(url)
                }
                else {
                    results.append(contentsOf: enumarateProjFolderURL(url: url))
                }
            }
        } catch {
            return results
        }
        
        return results
    }
}
