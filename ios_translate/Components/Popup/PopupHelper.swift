//
//  PopupHelper.swift
//  ios_translate
//
//  Created by ThuyetLN on 23/4/24.
//

import AppKit

protocol PopupContainerViewProtocol: NSView {
    var delegate: PopupContainerViewDelegate? { get set }
}
protocol PopupContainerViewDelegate: AnyObject {
    func dismiss(_ popup: PopupContainerViewProtocol, completion: (() -> Void)?)
}


class PopupHelper {
    static func popup(v: PopupContainerViewProtocol) -> PopupContainerView {
        let popupView = PopupContainerView()
        popupView.setContentView(v)
        popupView.show()
        return popupView
    }
}

class PopupContainerView: NSView, Popupable, PopupContainerViewDelegate {
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private let backgroundButton = AlphaBackgroundButton()
    private let contentContainerView = NSView().then {
        $0.cBackgroundColor = .windowBackgroundColor
        $0.cornerRadius = 10
    }
    
    private func setup() {
        backgroundButton.isBordered = false
        addSubview(backgroundButton)
        backgroundButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        addSubview(contentContainerView)
        contentContainerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.top.leading.greaterThanOrEqualTo(50)
        }
    }
    
    func setContentView(_ view: PopupContainerViewProtocol) {
        view.delegate = self
        contentContainerView.subviews.forEach {
            $0.removeFromSuperview()
        }
        contentContainerView.addSubview(view)
        view.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.top.equalToSuperview().inset(20)
        }
    }
    
    func dismiss(_ popup: PopupContainerViewProtocol, completion: (() -> Void)?) {
        self.dismiss(completion: completion)
    }
}
