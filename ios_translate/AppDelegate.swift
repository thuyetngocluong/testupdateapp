//
//  AppDelegate.swift
//  ios_translate
//
//  Created by ThuyetLN on 18/4/24.
//

import Cocoa
import KeyboardShortcuts
import Sparkle

extension KeyboardShortcuts.Name {
    static let commandR = Self("commandR", default: .init(.r, modifiers: [.command]))
}

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var checkForUpdateButton: NSMenuItem!
    private var isReloading = false
    
    lazy var updater = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
    
    static var shared: AppDelegate!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        Self.shared = self
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] (event) -> NSEvent? in
            guard let self = self else {
                return event
            }
            // Check for the specific key combination (e.g., Command + R)
            if event.modifierFlags.contains(.command) && event.characters?.lowercased() == "r" {
                guard !self.isReloading else { return nil }
                self.isReloading = true
                Task.init {
                    let progress = NSView().showProgress(title: "Reloading ...")
                    await AppDataManager.shared.reload()
                    progress.progress = 100
                    progress.dismiss { [weak self] in
                        self?.isReloading = false
                    }
                }
                
                // Return nil to prevent the event from being handled further
                return nil
            }
            
            // Return the event to continue handling
            return event
        }
        
    }
    @IBAction func checkForUpdate(_ sender: Any) {
        
        updater.checkForUpdates(nil)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
