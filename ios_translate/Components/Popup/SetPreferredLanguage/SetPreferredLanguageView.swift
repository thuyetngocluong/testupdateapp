//
//  SetPreferredLanguageView.swift
//  ios_translate
//
//  Created by ThuyetLN on 24/4/24.
//

import AppKit
import Combine



class SetPreferredLanguageView: BaseNibView, Popupable, PopupContainerViewProtocol {
    
    weak var delegate: (any PopupContainerViewDelegate)?
    
    
    @IBOutlet weak var searchSelectedLanguage: NSSearchField!
    @IBOutlet weak var searchUnselectedLanguageField: NSSearchField!
    @IBOutlet weak var selectedTableView: NSTableView!
    @IBOutlet weak var selectedContainerView: TrackingSizeNSView!
    
    @IBOutlet weak var unSelectedTableView: NSTableView!
    @IBOutlet weak var unSelectedContainerView: TrackingSizeNSView!
    
    private var selectedLanguages: [LanguageItem] = []
    private var filterredSelectedLanguages: [LanguageItem] = []
    
    private var unSelectedLanguages: [LanguageItem] = []
    private var filterredUnselectedLanguages: [LanguageItem] = []
        
    override func setup() {
        selectedLanguages = AppDataManager.shared.selectedApplication.languages
        selectedTableView.tableColumns.first?.title = "Selected Languages"
        selectedTableView.registerNibs(MainTranslateListLanguageCell.self)
        selectedTableView.delegate = self
        selectedTableView.dataSource = self
        selectedTableView.doubleAction = #selector(doubleClickRowSelected)
        selectedLanguages = AppDataManager.shared.selectedApplication.languages
        
        
        unSelectedLanguages = AppDataManager.shared.allLanguages.values.flatMap({ $0 }).filter {
            !selectedLanguages.contains($0)
        }
        
        unSelectedTableView.tableColumns.first?.title = "UnSelected Languages"
        unSelectedTableView.registerNibs(MainTranslateListLanguageCell.self)
        unSelectedTableView.delegate = self
        unSelectedTableView.dataSource = self
        
        unSelectedTableView.doubleAction = #selector(doubleClickRowUnselected)
        reloadUnSelectTableView()
        reloadSelectTableView()
        
        searchUnselectedLanguageField.textPulisher
            .sink { [weak self] _ in
                self?.reloadUnSelectTableView()
            }
            .store(in: &subscriptions)
        
        searchSelectedLanguage.textPulisher
            .sink { [weak self] _ in
                self?.reloadSelectTableView()
            }
            .store(in: &subscriptions)
        
        
        DispatchQueue.main.async {
            self.updateWidthColumns()
        }
        selectedContainerView
            .sizeChanged
            .sink { [weak self] in
                guard let self = self else { return }
                self.selectedTableView.tableColumns.forEach {
                    $0.width = self.selectedContainerView.bounds.width.rounded()-10
                }
            }
            .store(in: &subscriptions)
        unSelectedContainerView
            .sizeChanged
            .sink { [weak self] in
                guard let self = self else { return }
                self.unSelectedTableView.tableColumns.forEach {
                    $0.width = self.unSelectedContainerView.bounds.width.rounded()-10
                }
            }
            .store(in: &subscriptions)
    }
    
    func reloadUnSelectTableView() {
        let data = {
            if searchUnselectedLanguageField.stringValue.isEmpty {
                return self.unSelectedLanguages
            }
            return self.unSelectedLanguages.filter {
                $0.languageText.lowercased().contains(searchUnselectedLanguageField.stringValue.lowercased())
            }
        }()
        self.filterredUnselectedLanguages = data
        self.unSelectedTableView.reloadData()
        
    }
    
    func reloadSelectTableView() {
        let data = {
            if searchSelectedLanguage.stringValue.isEmpty {
                return self.selectedLanguages
            }
            return self.selectedLanguages.filter {
                $0.languageText.lowercased().contains(searchSelectedLanguage.stringValue.lowercased())
            }
        }()
        self.filterredSelectedLanguages = data
        self.selectedTableView.reloadData()
        
    }
    
    @objc func doubleClickRowUnselected() {
        let selectedRow = unSelectedTableView.selectedRow
        if selectedRow != -1 {
            self.selectedLanguages.append(filterredUnselectedLanguages[selectedRow])
            self.selectedLanguages.sort(by: { $0.languageText < $1.languageText })
            
            unSelectedLanguages.remove(at: selectedRow)
            self.unSelectedLanguages.sort(by: { $0.languageText < $1.languageText })
            
            self.reloadUnSelectTableView()
            self.reloadSelectTableView()
        }
    }
    
    @objc func doubleClickRowSelected() {
        let selectedRow = selectedTableView.selectedRow
        if selectedRow != -1 {
            self.unSelectedLanguages.append(filterredSelectedLanguages[selectedRow])
            self.unSelectedLanguages.sort(by: { $0.languageText < $1.languageText })
            
            selectedLanguages.remove(at: selectedRow)
            self.selectedLanguages.sort(by: { $0.languageText < $1.languageText })
            
            self.reloadUnSelectTableView()
            self.reloadSelectTableView()
        }
    }
    
    private
    func updateWidthColumns() {
        self.selectedTableView.tableColumns.forEach {
            $0.width = self.selectedContainerView.bounds.width.rounded()-10
        }
        self.unSelectedTableView.tableColumns.forEach {
            $0.width = self.unSelectedContainerView.bounds.width.rounded()-10
        }
    }

    @IBAction func onImport(_ sender: Any) {
       
        
        let progressView = self.superview!.superview!.showProgress(title: "Setting Language ...")
        Task.init {
            await AuthAPIRouter.updatePreferredLanguage(applicationID: AppDataManager.shared.selectedApplication.id,
                                                        languages: selectedLanguages).doRequest(responseDecodedTo: String.self)
            progressView.progress = 1
            await AppDataManager.shared.reloadUser()
            await AppDataManager.shared.fillRestOfLanguage { [weak progressView] text, progress in
                progressView?.title = text
                progressView?.progress = progress
            }
            await AppDataManager.shared.reload()
            progressView.progress = 100
            progressView.dismiss()
            delegate?.dismiss(self, completion: nil)
        }
    }
    
    @IBAction func onCancel(_ sender: Any) {
        delegate?.dismiss(self, completion: nil)
    }
}

extension SetPreferredLanguageView: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        switch tableView {
        case selectedTableView:
            return filterredSelectedLanguages.count
        default:
            return filterredUnselectedLanguages.count
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let language = {
            switch tableView {
            case selectedTableView:
                return filterredSelectedLanguages[row]
            default:
                return filterredUnselectedLanguages[row]
            }
        }()
        let cell = tableView.makeView(MainTranslateListLanguageCell.self)
        cell.bind(language: language)
        return cell
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        30
    }
}
