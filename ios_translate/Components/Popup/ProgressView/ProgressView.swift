//
//  ProgressView.swift
//  ios_translate
//
//  Created by ThuyetLN on 22/4/24.
//

import AppKit



class ProgressView: BaseNibView, Popupable {
    
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var button: AlphaBackgroundButton!
    
    @Published var progress: Double = 0
    @Published var title: String = ""
    
    override func setup() {
        $progress
            .receive(on: DispatchQueue.main)
            .assign(to: \.doubleValue, on: progressIndicator, ownership: .weak)
            .store(in: &subscriptions)
        
        $title
            .receive(on: DispatchQueue.main)
            .assign(to: \.stringValue, on: titleLabel, ownership: .weak)
            .store(in: &subscriptions)
        progressIndicator.startAnimation(nil)

    }
}
