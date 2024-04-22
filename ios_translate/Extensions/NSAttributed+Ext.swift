//
//  NSAttributed+Ext.swift
//  ios_translate
//
//  Created by ThuyetLN on 22/4/24.
//

import AppKit


extension NSAttributedString {
    static func centeredIconString(icon: NSImage, font: NSFont, iconSize: NSSize? = nil) -> NSAttributedString {
        let textAttachment = NSTextAttachment()
        textAttachment.image = icon
        
        let iconSize = iconSize ?? icon.size
        textAttachment.bounds = NSRect(origin: .init(x: 0, y: font.pointSize-iconSize.height), size: iconSize)
        return .init(attachment: textAttachment)
    }
    
    func ranges(of searchString: String) -> [NSRange] {
        var searchRange = NSRange(location: 0, length: self.length)
        var ranges: [NSRange] = []
        let string = self.string.lowercased()
        
        while searchRange.location != NSNotFound {
            searchRange = (string as NSString).range(of: searchString, options: [], range: searchRange)
            
            if searchRange.location != NSNotFound {
                ranges.append(searchRange)
                searchRange = NSRange(location: searchRange.location + searchRange.length,
                                      length: self.length - (searchRange.location + searchRange.length))
            }
        }
        
        return ranges
    }
}
