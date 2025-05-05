//
//  Color+AdaptiveText.swift
//  LinkPreviewExperiment
//
//  Created by William B on 04/05/2025.
//

import SwiftUI

/**
 Determine if we should use white or black text based on the background color

 Based on: https://swiftandtips.com/adaptive-text-color-in-swiftui-based-on-background
 */
extension Color {
    func luminance() -> Double {
        // 1. Convert SwiftUI Color to UIColor
        let uiColor = UIColor(self)

        // 2. Extract RGB values
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: nil)

        // 3. Compute luminance.
        return 0.2126 * Double(red) + 0.7152 * Double(green) + 0.0722 * Double(blue)
    }

    func isLight() -> Bool {
        return luminance() > 0.5
    }

    func adaptedTextColor() -> Color {
        return isLight() ? Color.black : Color.white
    }
}
