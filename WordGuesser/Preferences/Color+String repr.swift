//
//  Color+String repr.swift
//  WordGuesser
//
//  Created by dimss on 17.02.2026.
//

import SwiftUI

extension Color {
    /// A hex string in `#RRGGBBAA` format when available.
    @MainActor
    var hex: String? {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        guard UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a) else {
            return nil
        }
        let bytes = [r, g, b, a].map(Color.byte(from:))
        return String(format: "#%02X%02X%02X%02X", bytes[0], bytes[1], bytes[2], bytes[3])
    }
    
    /// Returns the byte value for a normalized color component.
    static func byte(from value: CGFloat) -> UInt8 {
        let byteValue = Int(value * 255) % 256
        return UInt8(truncatingIfNeeded: byteValue)
    }
    
    /// Returns a normalized component extracted from `value` at `index`.
    static func component(from value: Int64, at index: Int) -> Double {
        let byteValue = (value >> (index * 16)) & 0xff
        return Double(byteValue) / 255
    }
    
    /// Creates a color from a `#RRGGBBAA` string.
    init?(hex: String) {
        guard hex.count == 9 else {
            return nil
        }
        var hex = hex
        hex.removeFirst()
        guard let value = Int64(hex, radix: 16) else {
            return nil
        }
        let r = Color.component(from: value, at: 0)
        let b = Color.component(from: value, at: 1)
        let g = Color.component(from: value, at: 2)
        let a = Color.component(from: value, at: 3)
        self.init(red: r, green: g, blue: b, opacity: a)
    }
}
