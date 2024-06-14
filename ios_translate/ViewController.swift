//
//  ViewController.swift
//  ios_translate
//
//  Created by ThuyetLN on 18/4/24.
//

import Cocoa
import SnapKit
import Combine
import Sparkle


class ViewController: NSViewController {
    
    static var shared: ViewController?
    
    @IBOutlet var contentView: NSView!
    
    private var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Self.shared = self
        NSApplication.shared.windows.forEach { $0.title = "iOS Translate - v\(NSApplication.shared.getAppVersion() ?? "")" }
        
        AppDataManager.shared.$user
            .removeDuplicates()
            .filter({ $0 == nil })
            .sink { [weak self] _ in
                self?.setUpLoginView()
            }
            .store(in: &subscriptions)
    }
    
    private
    func setUpLoginView() {
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
