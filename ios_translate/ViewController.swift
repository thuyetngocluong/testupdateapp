//
//  ViewController.swift
//  ios_translate
//
//  Created by ThuyetLN on 18/4/24.
//

import Cocoa
import SnapKit
import Combine


class ViewController: NSViewController {
    
    @IBOutlet var contentView: NSView!
    
    private var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let loginView = LoginView()
        setContentView(loginView)
        
        loginView
            .loginSuccess
            .sink { [weak self] in
                self?.setContentView(MainTranslateView())
            }
            .store(in: &subscriptions)
    }
}
