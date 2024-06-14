//
//  AppDataManager.swift
//  ios_translate
//
//  Created by ThuyetLN on 19/4/24.
//

import Foundation
import CombineExt
import Combine


class AppDataManager {
    static let shared = AppDataManager()
    
    private var subscriptions = Set<AnyCancellable>()
    
    private
    init() {
        $selectedApplication
            .removeDuplicates()
            .flatMapLatest { application in
                Future<[Translation], Never>.init { promise in
                    guard application.id > 0 else {
                        promise(.success([]))
                        return;
                    }
                    Task.detached {
                        let translations = await AuthAPIRouter.getTranslations(applicationID: application.id).doRequest(responseDecodedTo: [Translation].self) ?? []
                        promise(.success(translations))
                    }
                }
            }
            .assign(to: \.translations, on: self, ownership: .weak)
            .store(in: &subscriptions)
        
        $user
            .compactMap({ $0 })
            .map(\.id)
            .removeDuplicates()
            .sink { [weak self] user in
                guard let self = self else { return }
                self.reloadAllLanguges()
            }
            .store(in: &subscriptions)
        
        $user
            .compactMap({ $0 })
            .sink { [weak self] user in
                guard let self = self else { return }
                self.selectedApplication = user.applications.first(where: { $0.id == self.selectedApplication.id }) ?? user.applications.first ?? selectedApplication
            }
            .store(in: &subscriptions)
    }
    
    @Published var allLanguages: [Language: [LanguageItem]] = [:]
    @Published var translations = [Translation]()
    @Published var selectedApplication: UserApplication = .init()
    @Published var user: User?
    
    func reloadTranslations() async {
        let translations = await AuthAPIRouter.getTranslations(applicationID: self.selectedApplication.id).doRequest(responseDecodedTo: [Translation].self)
        if let translations {
            self.translations = translations
        }
    }
    
    func reloadAllLanguges() {
        Task.init {
            let languages = await AuthAPIRouter.fetchLanguages.doRequest(responseDecodedTo: [LanguageItem].self)
            if let languages {
                self.allLanguages = Dictionary(grouping: languages, by: { $0.language })
            }
        }
    }
    
    func reloadUser() async {
        guard let userInfo = await AuthAPIRouter.checkMe.doRequest(responseDecodedTo: User.self) else {
            return
        }
        
        UserDefaults.standard.currentUser?.user = userInfo
        
        self.user = userInfo
    }
    
    func reload() async {
        await reloadUser()
        await reloadTranslations()
        await reloadAllLanguges()
    }
    
    func fillRestOfLanguage(progressTracking: ((String, Double) -> Void)? ) async {
        
        let translations = self.translations
        let languages = selectedApplication.languages
        guard let englishLanguage = selectedApplication.languages.first(where: { $0.language == .english && $0.countryCode == nil }) else {
            return
        }
        
        var languageNeedTranslates: [LanguageItem: [(translation: Translation, english: Translation.Item)]] = [:]
        
        for language in languages {
            let emptyTranslated = translations.compactMap({ translation -> (translation: Translation, english: Translation.Item)? in
                
                // Có tiếng anh
                guard let existEnglish = translation.translates.first(where: { $0.language == englishLanguage }),
                      !existEnglish.value.isEmpty
                else {
                    return nil
                }
                
                // Ngôn ngữ rỗng
                if let translates = translation.translates.first(where: { $0.language == language }),
                   !translates.value.isEmpty 
                {
                    return nil
                }
                
                return (translation, existEnglish)
            })
            guard !emptyTranslated.isEmpty else { continue }
            
            languageNeedTranslates[language] = emptyTranslated
        }
        
        let total = languageNeedTranslates.values.reduce(0, { $0 + $1.count })
        var currentPercent = Double.zero
        
        guard total != .zero else { return }
        
        for (language, needTranslate) in languageNeedTranslates {
            let texts = needTranslate.map({ $0.english.value })
            let totalTextOfLanguages = texts.count
            
            let percent = Double(totalTextOfLanguages)/Double(total)
            
            var currentPercentOfLanguage: Double = .zero
            
            
            progressTracking?("Translating english to \(language.languageAndCountryCode)", (currentPercent + currentPercentOfLanguage)*100)
            
            let results = await Utils.shared.translate(texts: texts,
                                                       languageCode: language.languageAndCountryCode,
                                                       context: self.selectedApplication.defaultContext) { text, process in
                currentPercentOfLanguage = currentPercent + (process/100)*0.5*percent
                progressTracking?("Translating english to \(language.languageAndCountryCode): \(text)", (currentPercent + currentPercentOfLanguage)*100)
            }
            
            
            guard results.count == texts.count else {
                currentPercent += percent
                continue
            }
            
            let updateTotal = texts.count
            var updateCount = 0
            
            for (idx, translation) in needTranslate.map(\.translation).enumerated() {
                
                _ = await AuthAPIRouter.updateTranslation(id: translation.id,
                                                          key: translation.key,
                                                          translated: results[safeIndex: idx] ?? "",
                                                          languageID: language.id)
                .doRequestToResponseData()
                
                currentPercentOfLanguage = currentPercent + (Double(updateCount)/Double(updateTotal))*0.5*percent + 0.5
                
                progressTracking?("Updating translate english to \(language.languageAndCountryCode): \(updateCount)/\(updateTotal)", (currentPercent + currentPercentOfLanguage)*100)
            
                updateCount += 1
            }
            currentPercent += percent
        }
    }
}
