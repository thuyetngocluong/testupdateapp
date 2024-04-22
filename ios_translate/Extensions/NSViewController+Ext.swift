//
//  NSViewController+Ext.swift
//  ios_translate
//
//  Created by ThuyetLN on 19/4/24.
//

import AppKit
import Combine


extension NSViewController {
    func setContentView(_ v: NSView) {
        self.view.subviews.forEach {
            $0.removeFromSuperview()
        }
        view.addSubview(v)
        v.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

class BaseNSViewController: NSViewController {
    lazy var subscription = Set<AnyCancellable>()
}
