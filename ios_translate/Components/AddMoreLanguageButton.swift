//
//  AddMoreLanguageButton.swift
//  ios_translate
//
//  Created by ThuyetLN on 22/4/24.
//

import AppKit
import Combine


class AddMoreLanguageButton: NSComboButton, NSMenuDelegate {
    
    private var subscriptions = Set<AnyCancellable>()
    
    private var selectedLanguages: [LanguageItem] = []
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private
    func setup() {
        title = "Set Preferred Languages"
        
        Publishers.CombineLatest(
            AppDataManager.shared
                .$selectedApplication.map(\.languages),
            AppDataManager.shared.$allLanguages
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] selected, all in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.selectedLanguages = selected
                self.reloadMenu(selectedLanguages: selected, all: all)
            }
        }
        .store(in: &subscriptions)
    }
    
    private
    func reloadMenu(selectedLanguages: [LanguageItem], all: [Language: [LanguageItem]]) {
        let unSelectedLanguages = all
            .mapValues({ $0.filter({ !self.selectedLanguages.contains($0) }) })
            .filter({ !$0.value.isEmpty })
            .sorted(by: { $0.key.rawValue < $1.key.rawValue })
        
        let menu = NSMenu(title: "Add More Languages")
        for language in selectedLanguages {
            let item = NSMenuItem(title: language.languageText,
                                  action: #selector(didSelectLanguage(_:)),
                                  keyEquivalent: "")
            item.representedObject = language.id
            item.isEnabled = true
            item.target = self
            item.state = .on
            menu.addItem(item)
        }
        
        let moreLanguageItem: NSMenuItem = {
            let moreLanguageItem = NSMenuItem(title: "More Languges", action: nil, keyEquivalent: "")
            moreLanguageItem.submenu = {
                let submenu = NSMenu(title: "")
                for (language, languageItems) in unSelectedLanguages {
                    // Check có các ngôn ngữ theo country không
                    let hasSubLanguage = !languageItems.filter({ $0.countryCode != nil }).isEmpty
                    
                    let menuItem = NSMenuItem(title: language.rawValue,
                                              action: !hasSubLanguage ? #selector(didSelectLanguage(_:)) : nil,
                                              keyEquivalent: "")
                    menuItem.representedObject = languageItems.first?.id
                    menuItem.isEnabled = true
                    menuItem.target = self
                    menuItem.state = .off
                    
                    menuItem.submenu = !hasSubLanguage ? nil : {
                        let sMenuItem = NSMenu(title: "")
                        for languageItem in languageItems {
                            let mi = NSMenuItem(title: languageItem.languageText,
                                                action: #selector(didSelectLanguage(_:)),
                                                keyEquivalent: "").then {
                                $0.representedObject = languageItem.id
                                $0.isEnabled = true
                                $0.target = self
                                $0.state = .off
                            }
                            sMenuItem.addItem(mi)
                        }
                        return sMenuItem
                    }()
                    
                    
                    submenu.addItem(menuItem)
                }
                return submenu
            }()
            return moreLanguageItem
        }()
        menu.addItem(moreLanguageItem)
        menu.delegate = self
        menu.selectionMode = .selectOne
        
        self.menu = menu
    }
    @objc
    func didSelectLanguage(_ action: NSMenuItem) {
        
        guard let languageID = action.representedObject as? Int,
              languageID >= 0,
              let language = AppDataManager.shared.allLanguages.values.flatMap({ $0 }).first(where: { $0.id == languageID })
        else {
            return
        }
        
        let newLanguages: Set<LanguageItem> = {
            var new = Set(self.selectedLanguages)
            if self.selectedLanguages.contains(language) {
                new.remove(language)
            } else {
                new.insert(language)
            }
            return new
        }()
        
        AppDataManager.shared.selectedApplication.languages = newLanguages.sorted(by: { $0.languageText < $1.languageText })
        let progressView = self.superview!.superview!.showProgress(title: "Setting Language ...")
        Task.init {
            await AuthAPIRouter.updatePreferredLanguage(applicationID: AppDataManager.shared.selectedApplication.id,
                                                        languages: Array(newLanguages)).doRequest(responseDecodedTo: String.self)
            progressView.progress = 50
            await AppDataManager.shared.reloadUser()
            progressView.progress = 100
            progressView.dismiss()
        }
    }
}
