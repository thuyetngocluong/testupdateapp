//
//  PreviewTranslateView.swift
//  ios_translate
//
//  Created by ThuyetLN on 23/4/24.
//

import AppKit
import Combine


class PreviewTranslateView: BaseNibView, PopupContainerViewProtocol {
    
    weak var delegate: PopupContainerViewDelegate?
    
    @IBOutlet weak var listLaguageView: MainTranslateListLanguageView!
    @IBOutlet weak var listTranslationView: TranslateView!
    
    @Published private var translations: [Translation] = []
    
    var onImport: (([Translation] ) -> Void)?
    
    override func setup() {
        let languages = AppDataManager.shared.selectedApplication.languages
        self.listLaguageView.selectedLanguage = languages.first ?? .init()
        self.listLaguageView.bind(languagesChangePublisher: AppDataManager.shared.$selectedApplication.map(\.languages).first().eraseToAnyPublisher())
        
        $translations
            .sink { [weak self] translations in
                self?.listTranslationView.bind(translations: translations)
            }
            .store(in: &subscriptions)
        
        listLaguageView
            .$selectedLanguage
            .assign(to: \.selectedLanguage, on: listTranslationView, ownership: .weak)
            .store(in: &subscriptions)
        
        listTranslationView.overrideHandleEdit = { [weak self] id, newKey, newValue, language in
            guard let self = self,
                  let idx = translations.firstIndex(where: { $0.id == id })
            else { return }
            var valueAtIdx = translations[idx]
            valueAtIdx.key = newKey
            if let matchedLanguageIdx = valueAtIdx.translates.firstIndex(where: { $0.language == language }) {
                valueAtIdx.translates[matchedLanguageIdx].value = newValue
            }
            translations[idx] = valueAtIdx
        }
    }
    
    func bind(translations: [Translation] ) {
        self.translations = translations
    }
    
    @IBAction func onCancel(_ sender: Any) {
        delegate?.dismiss(self, completion: nil)
    }
    
    @IBAction func onOK(_ sender: Any) {
        let translations = self.translations
        let capture = onImport
        delegate?.dismiss(self, completion: {
            capture?(translations)
        })
    }
}
