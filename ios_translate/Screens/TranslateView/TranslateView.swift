//
//  TranslateView.swift
//  ios_translate
//
//  Created by ThuyetLN on 19/4/24.
//

import AppKit
import Then
import Combine
import CombineExt

struct TranslateViewDataItem {
    var id: Int = -1
    var key: String = ""
    var english: String = ""
    var translated: String = ""
    
    private var searchKey: String = ""
    private var searchEnglish: String = ""
    private var searchTranslate: String = ""
    
    init(id: Int, key: String, english: String, translated: String) {
        self.id = id
        self.key = key
        self.english = english
        self.translated = translated
        
        self.searchKey = self.key.lowercased()
        self.searchEnglish = self.english.lowercased()
        self.searchTranslate = self.translated.lowercased()
    }
    
    func maching(_ key: String) -> Bool {
        let key = key.lowercased()
        guard !key.isEmpty else { return true }
        return searchKey.contains(key) || searchEnglish.contains(key) || searchTranslate.contains(key)
    }
}

class TranslateView: BaseNibView {
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var searchField: NSSearchField!
    
    static let languageItemCell =  NSUserInterfaceItemIdentifier("keyColumn")
    
    let columns: [Column] = [.key, .english, .translated]
    
    @Published var selectedLanguage: LanguageItem = .init()
    
    private var allData: [TranslateViewDataItem] = []
    private var dataSource: [TranslateViewDataItem] = []
    private var isResizingTableColumn = false
    private var textSearch: String = ""
    
    private var sizeChanged = PassthroughSubject<Void, Never>()
    
    override func setup() {
        setupTableView()
        searchField.textPulisher
            .throttle(for: 0.2, scheduler: DispatchQueue.global(), latest: true)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in
                guard let self = self else { return }
                self.textSearch = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                self.reloadData()
            }
            .store(in: &subscriptions)
    }
    
    private
    func setupTableView() {
        
        for column in columns {
            tableView.addTableColumn(.init(identifier: column.identifier).then {
                $0.resizingMask = []
                $0.headerCell.attributedStringValue = column.title.withAttributes([
                    .font(.systemFont(ofSize: 15, weight: .semibold)),
                    .paragraphStyle(NSMutableParagraphStyle().then { $0.alignment = .center })
                ])
                $0.headerCell.alignment = .center
                $0.minWidth = 100
            })
        }
        
        
        tableView.usesAutomaticRowHeights = true
        tableView.columnAutoresizingStyle = .noColumnAutoresizing
        
        
        tableView.registerNibs(LanguageItemCell.self, TranslateActionCell.self)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        Publishers.CombineLatest(AppDataManager.shared.$translations, $selectedLanguage)
            .map { translations, language -> [TranslateViewDataItem] in
                return translations.map { translation in
                    let translated = translation.translates.first(where: { $0.language == language.language })?.value ?? ""
                    let english = translation.translates.first(where: { $0.language == .english })?.value ?? ""
                    return TranslateViewDataItem(id: translation.id,
                                                 key: translation.key,
                                                 english: english,
                                                 translated: translated)
                }
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                guard let self = self else { return }
                self.allData = data
                self.reloadData()
            }
            .store(in: &subscriptions)
        
        $selectedLanguage
            .sink { [weak self] language in
                guard let self = self else { return }
                let headerCell = self.tableView.tableColumns
                    .first(where: { $0.identifier == Column.translated.identifier })?.headerCell
                
                headerCell?.attributedStringValue = {
                    language.languageText.withAttributes([
                        .font(.systemFont(ofSize: 15, weight: .semibold)),
                        .paragraphStyle(NSMutableParagraphStyle().then { $0.alignment = .center })
                    ])
                }()
            }
            .store(in: &subscriptions)
        
        
        DispatchQueue.main.async {
            self.updateWidthColumns()
        }
        sizeChanged
            .sink { [weak self] in
                self?.updateWidthColumns()
            }
            .store(in: &subscriptions)
    }
    
    override func resizeSubviews(withOldSize oldSize: NSSize) {
        super.resizeSubviews(withOldSize: oldSize)
        sizeChanged.send(())
    }
    
    override func menu(for event: NSEvent) -> NSMenu? {
        let point = tableView.convert(event.locationInWindow, from: nil)
        let row = tableView.row(at: point)
        
        switch event.type {
        case .rightMouseDown:
            let menu = NSMenu(title: "Contextual Menu")
            
            // Add menu items
            let menuItem1 = NSMenuItem(title: "Copy As String", action: #selector(handleCopy(_:)), keyEquivalent: "c").then {
                $0.representedObject = row
            }
            
            let menuItem2 = NSMenuItem(title: "Edit", action: #selector(handleEdit(_:)), keyEquivalent: "").then {
                $0.representedObject = row
            }
            
            menu.addItem(menuItem1)
            menu.addItem(menuItem2)
            
            return menu
        default:
            return super.menu(for: event)
        }
    }
    
    
    @objc func handleCopy(_ item: NSMenuItem) {
        guard let row = item.representedObject as? Int,
              row >= 0
        else { return }
        DispatchQueue.main.async {
           
            let data = self.dataSource[row]
            let copyString = "\"\(data.key)\" = \(data.translated.jsonStringfy());"

            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(copyString, forType: .string)
        }

    }
    
    @objc func handleEdit(_ item: NSMenuItem) {
        guard let row = item.representedObject as? Int,
              row >= 0
        else { return }
        let data = dataSource[row]
        DispatchQueue.main.async {
            let editView = self.showEdit(key: data.key, value: data.translated, language: self.selectedLanguage)
            editView.onOKAction = { [weak self] newKey, newValue, language in
                guard let self = self else { return }
                let processView = self.showProgress(title: "Editting")
                processView.progress = 0
                Task.init {
                    _ = await AuthAPIRouter.updateTranslation(id: data.id, key: newKey, translated: newValue, languageID: language.id).doRequestToResponseData()
                    processView.progress = 50
                    await AppDataManager.shared.reloadTranslations()
                    processView.progress = 100
                    processView.dismiss()
                }
            }
        }
    }
    
    private
    func updateWidthColumns() {
        let width = (self.bounds.width/CGFloat(self.tableView.tableColumns.count)).rounded() - 10
        self.tableView.tableColumns.forEach {
            $0.width = width
        }
    }
    
    private
    func reloadData() {
        self.dataSource = {
            guard !textSearch.isEmpty else {
                return allData
            }
            return allData.filter({
                $0.maching(textSearch)
            })
        }()
        self.tableView.reloadData()
    }
}

extension TranslateView: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        dataSource.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let tableColumn = tableColumn,
              let column = Column(identifier: tableColumn.identifier)
        else { return nil }
        let translation = dataSource[row]
        let cell = tableView.makeView(LanguageItemCell.self)
        switch column {
        case .key:
            cell.bind(text: translation.key, textSearch: textSearch)
        case .english:
            cell.bind(text: translation.english, textSearch: textSearch)
        case .translated:
            cell.bind(text: translation.translated, textSearch: textSearch)
        case .action:
            cell.bind(text: "", textSearch: textSearch)
        }
        return cell
    }
    
//    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
//        false
//    }
}

extension TranslateView {
    enum Column: String {
        case key
        case english
        case translated
        case action
        
        init?(identifier: NSUserInterfaceItemIdentifier) {
            if let value = Column(rawValue: identifier.rawValue) {
                self = value
            } else {
                return nil
            }
        }
        
        var title: String {
            switch self {
            case .key:
                return "Key"
            case .english:
                return "English"
            case .translated:
                return "Translated"
            case .action:
                return "Actions"
            }
        }
        
        var identifier: NSUserInterfaceItemIdentifier {
            .init(self.rawValue)
        }
    }
}
