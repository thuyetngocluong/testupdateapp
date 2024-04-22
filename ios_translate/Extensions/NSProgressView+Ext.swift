//
//  NSProgressView.swift
//  ios_translate
//
//  Created by ThuyetLN on 19/4/24.
//

import AppKit


extension NSProgressIndicator {

    func set(tintColor: NSColor) {
        guard let adjustedTintColor = tintColor.usingColorSpace(.deviceRGB) else {
            contentFilters = []

            return
        }

        let tintColorRedComponent = adjustedTintColor.redComponent
        let tintColorGreenComponent = adjustedTintColor.greenComponent
        let tintColorBlueComponent = adjustedTintColor.blueComponent

        let tintColorMinComponentsVector = CIVector(x: tintColorRedComponent, y: tintColorGreenComponent, z: tintColorBlueComponent, w: 0.0)
        let tintColorMaxComponentsVector = CIVector(x: tintColorRedComponent, y: tintColorGreenComponent, z: tintColorBlueComponent, w: 1.0)

        let colorClampFilter = CIFilter(name: "CIColorClamp")!
        colorClampFilter.setDefaults()
        colorClampFilter.setValue(tintColorMinComponentsVector, forKey: "inputMinComponents")
        colorClampFilter.setValue(tintColorMaxComponentsVector, forKey: "inputMaxComponents")

        contentFilters = [colorClampFilter]
    }
}
