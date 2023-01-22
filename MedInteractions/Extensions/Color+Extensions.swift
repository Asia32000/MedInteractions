//
//  Color+Extensions.swift
//  MedInteractions
//
//  Created by Joanna Staleńczyk on 22/01/2023.
//

import Foundation
import SwiftUI

extension Color {
    
    static let lightPurple = Color(hexString: "F2F2FF")
    static let darkPurple = Color(hexString: "2F2F86")
    static let buttonPurple = Color(hexString: "9999FF")
    static let segmentColor = Color(hexString: "CCCCFF")
    
    public init?(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        if !Scanner(string: hex).scanHexInt64(&int) {
            return nil
        }
        let r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // RGBA (32-bit)
            (r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF)
        default:
            return nil
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255)
    }
}
