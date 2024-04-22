//
//  BaseButton.swift
//  ios_translate
//
//  Created by ThuyetLN on 19/4/24.
//

import Foundation
import AppKit
import SwiftyAttributes
import Combine
import CombineExt


class BaseButton: NSButton {
    
    @IBInspectable var backgroundColor: NSColor = .clear {
        didSet {
            self.layer?.backgroundColor = backgroundColor.cgColor
        }
    }
    
    @IBInspectable var textColor: NSColor = .labelColor {
        didSet {
            self.attributedTitle = self.attributedTitle.withTextColor(textColor)
        }
    }
    
    @Published var isLoading = false
    
    private var subscriptions = Set<AnyCancellable>()
    
    private let processIndicator = BaseSpinIndicator()
    
    private var cTrackingArea: NSTrackingArea?
    
    private var mouseIsEnterred = false
    
    var didClickButton: (() -> Void)?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
      
        addSubview(processIndicator)
        processIndicator.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        $isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard let self = self else { return }
                processIndicator.removeFromSuperview()
                if isLoading {
                    processIndicator.isLoading = isLoading
                    addSubview(processIndicator)
                    processIndicator.snp.makeConstraints { $0.edges.equalToSuperview() }
                }
                
            }
            .store(in: &subscriptions)
        $isLoading
            .map({ !$0 })
            .assign(to: \.isEnabled, on: self, ownership: .weak)
            .store(in: &subscriptions)
        
        self.isBordered = false
        self.wantsLayer = true
        self.layer?.cornerRadius = 5
        self.layer?.backgroundColor = backgroundColor.cgColor
        
        
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        guard self.bounds.size != self.cTrackingArea?.rect.size else {
            return;
        }
        if let tracking = self.cTrackingArea {
            self.removeTrackingArea(tracking)
        }
        self.cTrackingArea = .init(rect: self.bounds,
                                   options: [.mouseEnteredAndExited, .activeInActiveApp],
                                   owner: self)
        self.addTrackingArea(cTrackingArea!)
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        mouseIsEnterred = true
        guard isEnabled else {
            alphaValue = 1
            return
        }
        alphaValue = 0.5
    }

    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        if mouseIsEnterred, isEnabled {
            didClickButton?()
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        mouseIsEnterred = false
        alphaValue = 1
    }
}
