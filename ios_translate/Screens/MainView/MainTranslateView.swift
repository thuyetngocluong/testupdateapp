//
//  MainTranslateView.swift
//  ios_translate
//
//  Created by ThuyetLN on 19/4/24.
//

import AppKit

class MainTranslateView: BaseNibView {
    
    @IBOutlet weak var selectApplicationButton: NSPopUpButton!
    
    @IBOutlet weak var splitView: NSSplitView!
    @IBOutlet weak var customLeftView: MainTranslateListLanguageView!
    @IBOutlet weak var customRightView: TranslateView!
    @IBOutlet weak var importButton: NSPopUpButton!
    @IBOutlet weak var exportButton: NSPopUpButton!
    
    private var applications: [UserApplication] = []
    
    @Published private var selectedLanguage: LanguageItem = .init()
    
    override func setup() {
        
        NSApplication.shared.mainWindow?.title = "iOS Translate - v\(NSApplication.shared.getAppVersion() ?? "")"
        
        AppDataManager.shared.$user
            .compactMap({ $0 })
            .removeDuplicates()
            .map(\.applications)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] applications in
                guard let self = self else { return }
                self.applications = applications
                self.selectApplicationButton.removeAllItems()
                for application in applications {
                    self.selectApplicationButton.addItem(withTitle: application.name)
                }
                AppDataManager.shared.selectedApplication = applications.first(where: { $0.id == AppDataManager.shared.selectedApplication.id }) ?? applications.first ?? .init()
            }
            .store(in: &subscriptions)
        
        AppDataManager.shared.$selectedApplication
            .receive(on: DispatchQueue.main)
            .sink { [weak self] application in
                self?.selectApplicationButton.setTitle(application.name)
            }
            .store(in: &subscriptions)
        
        customLeftView.bind(languagesChangePublisher: AppDataManager.shared.$selectedApplication.map(\.languages).eraseToAnyPublisher())
        
        AppDataManager.shared.$translations
            .sink { [weak self] translations in
                self?.customRightView.bind(translations: translations)
            }
            .store(in: &subscriptions)
        
        customLeftView.selectedLanguage = AppDataManager.shared.selectedApplication.languages.first ?? .init()
        customLeftView
            .$selectedLanguage
            .removeDuplicates()
            .assign(to: \.selectedLanguage, on: customRightView, ownership: .weak)
            .store(in: &subscriptions)
        
        
        importButton.menu = {
           let menu = NSMenu(title: "")
            menu.addItem(withTitle: "Import String Catalog",
                         action: #selector(importStringCatalog(_:)),
                         keyEquivalent: "")
            menu.addItem(withTitle: "Import Zip File",
                         action: #selector(importZip(_:)),
                         keyEquivalent: "")
            menu.items.forEach {
                $0.target = self
            }
            return menu
        }()
        importButton.title = "Import"
        
        exportButton.menu = {
           let menu = NSMenu(title: "")
            menu.addItem(withTitle: "Export To String Catalog",
                         action: #selector(exportToStringCatalog(_:)),
                         keyEquivalent: "")
            menu.addItem(withTitle: "Export To Zip",
                         action: #selector(exportToZip(_:)),
                         keyEquivalent: "")
            menu.addItem(withTitle: "Replace Zip",
                         action: #selector(replaceZip(_:)),
                         keyEquivalent: "")
            menu.items.forEach {
                $0.target = self
            }
            return menu
        }()
        exportButton.title = "Export"
    }
    
    @IBAction func didSelectedApplication(_ sender: NSPopUpButton) {
        let selectedApplication = self.applications[sender.indexOfSelectedItem]
        AppDataManager.shared.selectedApplication = selectedApplication
    }
    
    @IBAction func didTapAddNewKey(_ sender: Any) {
        let newKeyView = AddViewKeyView()
        newKeyView.didTapImport = { [weak self] keys, context in
            guard let self = self else { return }
            let languageCodes = Set(AppDataManager.shared.selectedApplication.languages.map { $0.languageAndCountryCode })
            self.translate(keys: keys, context: context, languageCodes: Array(languageCodes))
        }
        newKeyView.show()
        
       
    }
    
    private
    func translate(keys: [String], context: String, languageCodes: [String]) {
        let progressPopup = showProgress(title: "Translating...")
        Task.init {
            let response = await Utils.shared.translate(texts: keys,
                                         context: context,
                                         languageCodes: languageCodes) { [weak progressPopup] text, percent in
                progressPopup?.title = "Translating: \(text)"
                progressPopup?.progress = percent
            }
            
            let languages = AppDataManager.shared.selectedApplication.languages
            
            let translations = keys.enumerated().map { (idx, key) in
                var translation = Translation()
                translation.key = key
                translation.translates = []
                for language in languages {
                    var item = Translation.Item()
                    item.language = language
                    item.value = response[language.languageAndCountryCode]?[safeIndex: idx] ?? ""
                    translation.translates.append(item)
                }
                return translation
            }
            
            progressPopup.dismiss { [weak self] in
                self?.showPreview(translations: translations)
            }
        }
        
        
    }
    
    private
    func showPreview(translations: [Translation]) {
        let preview = PreviewTranslateView()
        preview.bind(translations: translations)
        preview.onImport = { [weak self] newTranslations in
            self?.importTranslations(translations: newTranslations)
        }
        
        let popup = PopupHelper.popup(v: preview)
        
    }
    
    private
    func importTranslations(translations: [Translation]) {
        let progressView = showProgress(title: "Importing")
        Task.init {
            await Utils.shared.createTranslations(translations: translations) { [weak progressView] text, percent in
                progressView?.title = "Importing: \(text)"
                progressView?.progress = percent
            }
            await AppDataManager.shared.reloadTranslations()
            progressView.dismiss()
        }
    }
    @objc func exportToZip(_ sender: Any) {
        exportButton.title = "Export"
        ExportUtils.shared.exportToZip()
    }
    @objc func exportToStringCatalog(_ sender: Any) {
        exportButton.title = "Export"
        ExportUtils.shared.exportToStringCatalogs()
    }
    @objc func replaceZip(_ sender: Any) {
        exportButton.title = "Export"
        ExportUtils.shared.replaceZip()
    }
    
    @objc func importStringCatalog(_ sender: Any) {
        importButton.title = "Import"
        ImportUtils.shared.importFromStringCatalog { [weak self] translations in
            guard let self = self,
                  !translations.isEmpty
            else { return }
            
            DispatchQueue.main.async {
                self.showPreview(translations: translations)
            }
        }
    }
    
    @objc func importZip(_ sender: Any) {
        importButton.title = "Import"
        ImportUtils.shared.importFromZip { [weak self] translations in
            guard let self = self,
                  !translations.isEmpty
            else { return }
            
            DispatchQueue.main.async {
                self.showPreview(translations: translations)
            }
        }
    }
    
    @IBAction func didClickSetLanguages(_ sender: Any) {
        PopupHelper.popup(v: SetPreferredLanguageView())
    }
    
    @IBAction func logout(_ sender: Any) {
        UserDefaults.standard.currentUser = nil
        AppDataManager.shared.user = nil
    }
    
}
