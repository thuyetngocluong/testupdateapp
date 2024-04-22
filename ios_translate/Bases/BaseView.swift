//
//  BaseView.swift
//  ios_translate
//
//  Created by ThuyetLN on 19/4/24.
//

import AppKit
import SnapKit
import Combine


class BaseNibView: NSView {
    
    internal lazy var subscriptions: Set<AnyCancellable> = .init()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        _loadView()
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _loadView()
        setup()
    }
    
    func setup() {
        
    }
    
    private
    func _loadView() {
        var topLevelObjects: NSArray?
        let success = Bundle.main.loadNibNamed(Self.className().components(separatedBy: ".").last!, owner: self, topLevelObjects: &topLevelObjects)
        guard success,
              let view = topLevelObjects?.first(where: { $0 is NSView }) as? NSView
        else {
            return
        }
        self.addSubview(view)
        view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
