//
//  MainTranslateView.swift
//  ios_translate
//
//  Created by ThuyetLN on 19/4/24.
//

import AppKit

class MainTranslateView: BaseNibView {
    
    @IBOutlet weak var selectApplicationButton: NSPopUpButton!
    
    @IBOutlet weak var splitView: NSSplitView!
    @IBOutlet weak var customLeftView: MainTranslateListLanguageView!
    @IBOutlet weak var customRightView: TranslateView!
    
    private var applications: [UserApplication] = []
    
    override func setup() {
        AppDataManager.shared.$user
            .removeDuplicates()
            .map(\.applications)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] applications in
                guard let self = self else { return }
                self.applications = applications
                self.selectApplicationButton.removeAllItems()
                for application in applications {
                    self.selectApplicationButton.addItem(withTitle: application.name)
                }
                AppDataManager.shared.selectedApplication = applications.first(where: { $0.id == AppDataManager.shared.selectedApplication.id }) ?? applications.first ?? .init()
            }
            .store(in: &subscriptions)
        
        AppDataManager.shared.$selectedApplication
            .receive(on: DispatchQueue.main)
            .sink { [weak self] application in
                self?.selectApplicationButton.setTitle(application.name)
            }
            .store(in: &subscriptions)
        
        customLeftView.$selectedLanguage
            .assign(to: \.selectedLanguage, on: customRightView, ownership: .weak)
            .store(in: &subscriptions)
    }
    
    @IBAction func didSelectedApplication(_ sender: NSPopUpButton) {
        let selectedApplication = self.applications[sender.indexOfSelectedItem]
        AppDataManager.shared.selectedApplication = selectedApplication
    }
    
}
