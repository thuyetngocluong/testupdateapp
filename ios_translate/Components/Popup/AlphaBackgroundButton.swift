//
//  AlphaBackgroundButton.swift
//  ios_translate
//
//  Created by ThuyetLN on 22/4/24.
//

import AppKit

class AlphaBackgroundButton: NSButton {
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
        alphaValue = 0.5
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.withAlphaComponent(0.5).cgColor
        subviews.forEach {
            $0.wantsLayer = true
            $0.layer?.backgroundColor = NSColor.clear.cgColor
            $0.alphaValue = 0
        }
    }
}
