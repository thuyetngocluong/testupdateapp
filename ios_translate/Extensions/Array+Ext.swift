//
//  Array+Ex.swift
//  ios_translate
//
//  Created by ThuyetLN on 23/4/24.
//

import Foundation


extension Array {
    
    subscript(safeIndex idx: Int) -> Element? {
        get {
            if idx >= 0, idx < count {
                return self[idx]
            }
            return nil
        }
        set {
            if let newValue, idx >= 0, idx < count {
                self[idx] = newValue
            }
        }
    }
    
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
