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
}
