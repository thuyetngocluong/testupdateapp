//
//  LoginView.swift
//  ios_translate
//
//  Created by ThuyetLN on 19/4/24.
//

import AppKit
import Combine
//import CombineCocoa
import PromiseKit


class LoginView: BaseNibView {
    
    @IBOutlet weak var usernameTextField: NSTextField!
    @IBOutlet weak var passwordTextField: NSTextField!
    @IBOutlet weak var loginButton: BaseButton!
    @IBOutlet weak var alphaButton: AlphaBackgroundButton!
    @IBOutlet weak var ipTextField: NSTextField!
    
    private var _loginSuccessPromise: ((Swift.Result<Void, Never>) -> Void)?
    lazy var loginSuccess: Future<Void, Never> = .init { [weak self] promise in
        self?._loginSuccessPromise = promise
    }
    
    private var totalClick: Int = 0
    
    override func setup() {
        alphaButton.alphaValue = 0
        Publishers.CombineLatest(
            usernameTextField.textPulisher,
            passwordTextField.textPulisher
        )
        .map { $0.0.count >= 1 && $0.1.count >= 6 }
        .assign(to: \.isEnabled, on: loginButton, ownership: .weak)
        .store(in: &subscriptions)
        
        Task.init {
            await validateUser()
        }
        
        loginButton.didClickButton = { [weak self] in
            guard let self = self else { return }
            if !ipTextField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                UserDefaults.standard.currentHost = ipTextField.stringValue
            }
            self.loginButton.isLoading = true
            Task.init {
                defer {
                    self.loginButton.isLoading = false
                }
                guard let userInfo = await AuthAPIRouter.login(username: self.usernameTextField.stringValue, password:      self.passwordTextField.stringValue).doRequest(responseDecodedTo: UserWithAuthenticationInfo.self) else {
                    return
                }
                UserDefaults.standard.currentUser = userInfo
                
                await self.validateUser()
                
                self._loginSuccessPromise?(.success(()))
            }
        }
    }
    
    private
    func validateUser() async {
        guard let userInfo = await AuthAPIRouter.checkMe.doRequest(responseDecodedTo: User.self) else {
            return
        }
        
        UserDefaults.standard.currentUser?.user = userInfo
        
        AppDataManager.shared.user = userInfo
        
        self._loginSuccessPromise?(.success(()))
    }
    @IBAction func clickAction(_ sender: Any) {
        totalClick += 1
        if totalClick > 15 {
            ipTextField.superview?.isHidden = false
        }
    }
}
