//
//  AddViewKeyView.swift
//  ios_translate
//
//  Created by ThuyetLN on 23/4/24.
//

import AppKit


class AddViewKeyView: BaseNibView, Popupable, NSTextViewDelegate {
    
    @IBOutlet weak var contextTextField: NSTextField!
    @IBOutlet var keysTextView: NSTextView!
    @IBOutlet weak var importButton: NSButton!
    
    var didTapImport: ((_ keys: [String], _ context: String) -> Void)?
    
    override func setup() {
        contextTextField.stringValue = AppDataManager.shared.selectedApplication.defaultContext
        keysTextView.delegate = self
    }
    @IBAction func didTapCancel(_ sender: Any) {
        dismiss()
    }
    @IBAction func didTapImport(_ sender: Any) {
        let capture = didTapImport
        
        let keys = keysTextView.string.components(separatedBy: "\n").filter({ !$0.isEmpty })
        let context = contextTextField.stringValue
        
        dismiss {
            capture?(keys, context)
        }
    }
    
    func textDidChange(_ notification: Notification) {
        let count = keysTextView.string
            .components(separatedBy: "\n")
            .filter({ !$0.trimmingCharacters(in: .whitespaces).isEmpty })
            .count
        if count == 0 {
            importButton.title = "Import "
        } else {
            importButton.title = "Import \(count) key"
        }
    }
}
