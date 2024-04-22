//
//  NSTableView+Ext.swift
//  ios_translate
//
//  Created by ThuyetLN on 19/4/24.
//

import AppKit


extension NSTableView {
    func registerNibs(_ classes: AnyClass... ) {
        for aClass in classes {
            let className = String(describing: aClass)
            self.register(NSNib(nibNamed: String(describing: aClass), bundle: .main), forIdentifier: .init(className))
        }
    }
    
    func makeView<T>(_ aClass: T.Type) -> T {
        let className = String(describing: aClass.self)
        return self.makeView(withIdentifier: .init(className), owner: self) as! T
    }
}
