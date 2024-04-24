//
//  NSView+Ext.swift
//  ios_translate
//
//  Created by ThuyetLN on 19/4/24.
//

import AppKit


extension NSView {
    @IBInspectable var cBackgroundColor: NSColor {
        get { .clear }
        set {
            self.wantsLayer = true
            self.layer?.backgroundColor = newValue.cgColor
        }
    }
    @IBInspectable var cornerRadius: CGFloat {
        get { .zero }
        set {
            self.wantsLayer = true
            self.layer?.cornerRadius = newValue
        }
    }
}



extension NSView {
    func showProgress(title: String) -> ProgressView {
        let new = ProgressView()
        new.title = title
        new.show()
        return new
    }
    
    func showEdit(key: String, value: String, language: LanguageItem) -> EditLanguageItemView {
        let new = EditLanguageItemView()
        new.key = key
        new.value = value
        new.valueTitle = "Value - \(language.languageText)"
        new.language = language
        new.show()
        return new
    }
}
