//
//  MainTranslateListLanguageCell.swift
//  ios_translate
//
//  Created by ThuyetLN on 19/4/24.
//

import AppKit


class MainTranslateListLanguageCell: NSTableCellView {
    
    @IBOutlet weak var languageCodeLabel: NSTextField!
    @IBOutlet weak var titleTextField: NSTextField!
    
    func bind(language: LanguageItem) {
        languageCodeLabel.stringValue = language.language.languageCode
        titleTextField.stringValue = language.languageText
    }
}
