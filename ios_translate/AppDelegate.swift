//
//  AppDelegate.swift
//  ios_translate
//
//  Created by ThuyetLN on 18/4/24.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
//        Task.init {
//            for language in Language.allCases {
//                for countryCode in language.countryCodes {
//                    await AuthAPIRouter.updateLanguage(.init().with {
//                        $0.language = language
//                        $0.countryCode = countryCode
//                    }).doRequestToData()
//                }
//            }
//        }
        
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
