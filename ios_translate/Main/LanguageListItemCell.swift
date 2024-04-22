//
//  LanguageListItemCell.swift
//  ios_translate
//
//  Created by ThuyetLN on 18/4/24.
//

import AppKit


class LanguageListItemCell: NSTableCellView {
    
    @IBOutlet weak var label: NSTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        label.stringValue = "HJello"
    }
}
