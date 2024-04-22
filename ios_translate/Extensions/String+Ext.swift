//
//  String+Ext.swift
//  ios_translate
//
//  Created by ThuyetLN on 22/4/24.
//

import Foundation


extension String {
    func removingWhiteSpaceAndNewLines() -> String {
        self.replacingOccurrences(of: "\\s+|\\n", with: "", options: .regularExpression, range: nil)
    }
    
    func jsonStringfy() -> String {
        if let jsonData = try? JSONSerialization.data(withJSONObject: ["_": self]),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            
            let startIndex = jsonString.index(jsonString.startIndex, offsetBy: 5)
            let endIndex = jsonString.index(jsonString.endIndex, offsetBy: -2)
            return String(jsonString[startIndex...endIndex])
        }
        return self
    }
}
