//
//  LanguageListCell.swift
//  ios_translate
//
//  Created by ThuyetLN on 18/4/24.
//

import AppKit

class LanguageListCell: NSTableCellView {
    
    @IBOutlet weak var tableView: NSTableView!
    
    let languageListItemCell = NSUserInterfaceItemIdentifier("LanguageListItemCell")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.register(NSNib(nibNamed: "LanguageListItemCell", bundle: .main), forIdentifier: languageListItemCell)
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.reloadData()
    }
    
}

extension LanguageListCell: NSTableViewDataSource , NSTableViewDelegate{
    func numberOfRows(in tableView: NSTableView) -> Int {
        20
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: languageListItemCell, owner: self) as! LanguageListItemCell
        
        return cell
    }
}
