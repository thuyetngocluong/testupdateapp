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
    
    @IBOutlet var contentView: NSView!
    
    private var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AppDataManager.shared.$user
            .removeDuplicates()
            .filter({ $0 == nil })
            .sink { [weak self] _ in
                self?.setUpLoginView()
            }
            .store(in: &subscriptions)
        
        DispatchQueue.main.async {
            let updater = SUUpdater.shared()
            updater?.feedURL = URL(string: "some mystery location")
            updater?.checkForUpdates(self)
        }
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
