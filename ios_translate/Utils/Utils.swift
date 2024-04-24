//
//  Utils.swift
//  ios_translate
//
//  Created by ThuyetLN on 23/4/24.
//

import Foundation


struct Utils {
    
    static let shared = Utils()
    
    func translate(texts: [String], context: String, languageCodes: [String], progressTracking: ((String, Double) -> Void)? = nil ) async -> [String: [String]] {
        let total = texts.count
        var done = 0
        progressTracking?("\(done)/\(total)", 0)
        guard !texts.isEmpty else {
            return [:]
        }
        let chunks = texts.chunked(into: 10)
        var result = [String: [String]]()
        for chunk in chunks {
            let resultChunk = await withTaskGroup(of: (idx: Int, value: [String: String]).self, returning: [String: [String]].self) { group in
                for (idx, text) in chunk.enumerated() {
                    group.addTask {
                        let response = await _translate(text: text, context: context, languageCodes: languageCodes)
                        return (idx, response)
                    }
                }
                var result: [String: [String]] = [:]
                var grouped: [(idx: Int, value: [String: String])] = []
                for await result in group {
                    grouped.append(result)
                }
                grouped.sort(by: { $0.idx < $1.idx })
                for (_, aValueGroup) in grouped {
                    for (k, v) in aValueGroup {
                        result[k, default: []].append(v)
                    }
                }
                return result
            }
            
            for (k, v) in resultChunk {
                result[k, default: []].append(contentsOf: v)
            }
            
            done += chunk.count
            
            progressTracking?("\(done)/\(total)", Double(done)*100/Double(total))
        }
        
        return result
    }
    
    private func _translate(text: String, context: String, languageCodes: [String], tryCount: Int = 1) async -> [String: String] {
        guard tryCount >= 0 else {
            return [:]
        }
        
        let response = await TranslateAPIRouter.translate(text: text, context: context, languageCodes: languageCodes).doRequest(responseDecodedTo: [String: String].self)
        if let response {
            return response
        } else {
            return await _translate(text: text, context: context, languageCodes: languageCodes, tryCount: tryCount-1)
        }
    }
    
    
    func createTranslations(translations: [Translation], progressTracking: ((String, Double) -> Void)? = nil ) async {
        let total = translations.count
        var done = 0
        guard !translations.isEmpty else { return }
        
        for translation in translations {
            await TranslateAPIRouter.importNewKey(translation: translation).doRequestToData()
            done += 1
            progressTracking?("\(done)/\(total)", Double(done)*100/Double(total))
        }
    }
    
}
