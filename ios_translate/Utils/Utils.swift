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

extension Utils {
    func translate(texts: [String], languageCode: String, context: String, progressTracking: ((String, Double) -> Void)? = nil ) async -> [String] {
        let total = texts.count
        var done = 0
        let chunksOfChunkedTexts = texts.chunked(into: 5).chunked(into: 10)
        
        var result = [String]()
        
        for chunk in chunksOfChunkedTexts {
            let resultChunk = await withTaskGroup(of: (idx: Int, value: [String]).self, returning: [String].self) { group in
                for (idx, texts) in chunk.enumerated() {
                    group.addTask {
                        let response = await _translate(texts: texts, context: context, languageCode: languageCode)
                        return (idx, response)
                    }
                }
                var grouped: [(idx: Int, value: [String])] = []
                for await result in group {
                    grouped.append(result)
                    done += result.value.count
                    progressTracking?("\(done)/\(total)", Double(done)*100/Double(total))
                }
                                 
                return grouped.sorted(by: { $0.idx < $1.idx }).flatMap({ $0.value })
            }
            result.append(contentsOf: resultChunk)
        }
        return result
    }
    
    private func _translate(texts: [String], context: String, languageCode: String, tryCount: Int = 1) async -> [String] {
        guard tryCount >= 0 else {
            return Array(repeating: "", count: texts.count)
        }
        
        let response = await TranslateAPIRouter.translateTexts(texts: texts,
                                                               context: context, 
                                                               languageCode: languageCode).doRequest(responseDecodedTo: [String: [String]].self)
        if let rs = response?[languageCode] as? [String],
           rs.count == texts.count
        {
            return rs
        } else {
            return await _translate(texts: texts, context: context, languageCode: languageCode, tryCount: tryCount-1)
        }
    }
}
