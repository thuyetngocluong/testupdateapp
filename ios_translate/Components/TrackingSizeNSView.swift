//
//  TrackingSizeNSView.swift
//  ios_translate
//
//  Created by ThuyetLN on 24/4/24.
//

import AppKit
import Combine


class TrackingSizeNSView: NSView {
    private(set) var sizeChanged = PassthroughSubject<Void, Never>()
    
    override func resizeSubviews(withOldSize oldSize: NSSize) {
        super.resizeSubviews(withOldSize: oldSize)
        sizeChanged.send(())
    }
}
