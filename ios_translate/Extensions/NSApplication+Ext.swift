//
//  NSApplication+Ext.swift
//  ios_translate
//
//  Created by ThuyetLN on 25/4/24.
//

import AppKit


extension NSApplication {
    func getAppVersion() -> String? {
        if let infoDict = Bundle.main.infoDictionary {
            if let shortVersion = infoDict["CFBundleShortVersionString"] as? String {
                return "\(shortVersion)"
            }
        }
        return nil
    }
}
