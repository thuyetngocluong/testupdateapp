//
//  MainTranslateListLanguageView.swift
//  ios_translate
//
//  Created by ThuyetLN on 19/4/24.
//

import AppKit


class MainTranslateListLanguageView: BaseNibView {
    
    @IBOutlet weak var tableView: NSTableView!
    
    private var dataSource: [LanguageItem] = []
    
    @Published var selectedLanguage: LanguageItem = .init()
    
    override func setup() {
        tableView.rowSizeStyle = .custom
        tableView.registerNibs(MainTranslateListLanguageCell.self)
        tableView.delegate = self
        tableView.dataSource = self
        
        AppDataManager
            .shared
            .$selectedApplication
            .map(\.languages)
            .withLatestFrom($selectedLanguage, resultSelector: { return ($0, $1) })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] languages, selectedLanguage in
                guard let self = self else { return }
                
                self.dataSource = languages
                self.tableView.reloadData()
                if let idx = self.dataSource.firstIndex(of: selectedLanguage) {
                    self.tableView.selectRowIndexes(.init(integer: idx), byExtendingSelection: false)
                }
            }
            .store(in: &subscriptions)
        
        $selectedLanguage
            .removeDuplicates()
            .sink { [weak self] language in
                guard let self = self else { return }
                if let idx = self.dataSource.firstIndex(of: language) {
                    self.tableView.selectRowIndexes(.init(integer: idx), byExtendingSelection: false)
                }
            }
            .store(in: &subscriptions)
    }
}

extension MainTranslateListLanguageView: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        dataSource.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(MainTranslateListLanguageCell.self)
        cell.bind(language: dataSource[row])
        return cell
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        30
    }
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let tableView = notification.object as? NSTableView else {
            return
        }
        if tableView.selectedRow != -1 {
            selectedLanguage = dataSource[tableView.selectedRow]
        } else if let idx = self.dataSource.firstIndex(of: selectedLanguage) {
            self.tableView.selectRowIndexes(.init(integer: idx), byExtendingSelection: false)
        }
    }
}
