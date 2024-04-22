//
//  EditLanguageItem.swift
//  ios_translate
//
//  Created by ThuyetLN on 22/4/24.
//

import AppKit


class EditLanguageItemView: BaseNibView, Popupable {
    
    @IBOutlet weak var keyTextField: NSTextField!
    @IBOutlet weak var valueTextField: NSTextField!
    
    var onOKAction: ((String, String, LanguageItem) -> Void)?
    
    @Published var key: String = ""
    @Published var value: String = ""
    var language: LanguageItem = .init()
    
    override func setup() {
        $key
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .assign(to: \.stringValue, on: keyTextField, ownership: .weak)
            .store(in: &subscriptions)
        
        $value
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .assign(to: \.stringValue, on: valueTextField, ownership: .weak)
            .store(in: &subscriptions)
        
        keyTextField.textPulisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .assign(to: \.key, on: self, ownership: .weak)
            .store(in: &subscriptions)
        
        valueTextField.textPulisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .assign(to: \.value, on: self, ownership: .weak)
            .store(in: &subscriptions)
    }
    
    @IBAction func onCancel(_ sender: Any) {
        dismiss()
    }
    
    @IBAction func onOK(_ sender: Any) {
        let capture = onOKAction
        let key = self.key
        let value = self.value
        let language = self.language
        dismiss {
            capture?(key, value, language)
        }
    }
}
