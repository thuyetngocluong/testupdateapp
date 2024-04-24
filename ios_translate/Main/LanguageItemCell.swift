//
//  LanguageItemCell.swift
//  ios_translate
//
//  Created by ThuyetLN on 18/4/24.
//

import AppKit
import SwiftyAttributes


class LanguageItemCell: NSTableCellView, NSTextFieldDelegate {
    
    private let textBlockPecentSymbol = NSTextBlock()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.cBackgroundColor = NSColor.clear
        textField?.backgroundColor = .clear
        textField?.delegate = self
        textField?.placeholderString = "<<Empty>>"
    }
    
    func bind(text: String, textSearch: String) {
        let attribute = {
            let attribute = text.withAttribute(.backgroundColor(.clear))
            while true {
                let range = attribute.mutableString.range(of: "%@")
                guard range.location != NSNotFound else {
                    break
                }
                attribute.replaceCharacters(in: range, with: NSAttributedString.centeredIconString(icon: .init(named: "ic_percent_a")!,
                                                                                                   font: .systemFont(ofSize: 13)))
            }
            
            if !textSearch.isEmpty {
                for range in attribute.ranges(of: textSearch) {
                    attribute.addAttributes([
                        .textColor(.black),
                        .backgroundColor(.systemYellow)
                    ], range: range)
                }
            }
            
            return attribute
        }()
        
        textField?.attributedStringValue = attribute
        textField?.allowsEditingTextAttributes = true
        
    }
    
    
    func controlTextDidChange(_ obj: Notification) {
        print("CONTROL")
    }
}

extension Range where Bound == String.Index {
    func rangeInt(from string: String) -> Range<Int> {
        let lowerBound = string.distance(from: string.startIndex, to: self.lowerBound)
        let upperBound = string.distance(from: string.startIndex, to: self.upperBound)
        
        // Create a Range<Int>
        return lowerBound..<upperBound
    }
}
