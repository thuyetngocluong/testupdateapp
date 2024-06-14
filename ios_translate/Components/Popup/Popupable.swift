//
//  Popupable.swift
//  ios_translate
//
//  Created by ThuyetLN on 22/4/24.
//

import AppKit


protocol Popupable: NSView {
    func show()
    func dismiss(completion: (() -> Void)?)
}

extension Popupable {
    func show() {
        guard let contentView = NSApplication.shared.keyWindow?.contentView ?? NSApplication.shared.mainWindow?.contentView ?? ViewController.shared?.view else {
            return;
        }
        contentView.addSubview(self)
        self.autoresizesSubviews = true
        self.autoresizingMask = [.height, .width, .maxXMargin, .maxYMargin, .minXMargin, .minYMargin]
        self.frame = contentView.bounds
    }
    
    func dismiss(completion: (() -> Void)? = nil ) {
        NSAnimationContext.runAnimationGroup { [weak self] ctx in
            ctx.duration = 0.3
            self?.animator().alphaValue = 0
        } completionHandler: { [weak self] in
            self?.removeFromSuperview()
            completion?()
        }
    }
}
