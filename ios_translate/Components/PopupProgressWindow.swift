//
//  PopupProgressWindow.swift
//  ios_translate
//
//  Created by ThuyetLN on 22/4/24.
//

import AppKit

class PopupProgressWindow: NSWindowController {
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Center the window on the screen
        self.window?.center()
        
        // Make the window appear as a popup
//        self.window?.styleMask.remove(.resizable)
//        self.window?.styleMask.insert(.titled)
//        self.window?.styleMask.insert(.closable)
//        self.window?.isMovableByWindowBackground = true
//        self.window?.titleVisibility = .hidden
//        self.window?.titlebarAppearsTransparent = true
//
//        
        
        self.window?.level = .screenSaver
    }
}
