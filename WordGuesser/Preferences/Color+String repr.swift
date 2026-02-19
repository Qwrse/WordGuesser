//
//  Color+String repr.swift
//  WordGuesser
//
//  Created by dimss on 17.02.2026.
//

import SwiftUI

extension Color {
    /// Access string in format "#rrggbbaa" if `self` can be represented in
    /// red, green, blue, alpha (opacity) format; otherwise false.
    ///
    /// Each pair of symbols is an integer value from 0 to 255 in hexadecimal radix.
    @MainActor
    var hex: String? {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        guard UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a) else {
            return nil
        }
        let bytes = [r, g, b, a].map(Color.toByte)
        return String(format: "#%02X%02X%02X%02X", bytes[0], bytes[1], bytes[2], bytes[3])
    }
    
    /// Returns UInt8 representation of float part of `value`.
    static func toByte(_ value: CGFloat) -> UInt8 {
        let char = Int(value * 255) % 256
        return UInt8(truncatingIfNeeded: char)
    }
    
    /// Returns normalised value at position index in binary mask.
    ///
    /// Separates binaryValue on blocks of Int8,
    /// reads block at position index,
    /// returns value / 255.
    static func fromBinary(_ binaryValue: Int64, at index: Int) -> Double {
        let char = (binaryValue >> (index * 16)) & 0xff
        return Double(char) / 255
    }
    
    /// Creates color from hex representation.
    ///
    /// String should be in format "#rrggbbaa", where
    /// rr, gg, bb, aa are hexadecimal numbers from 0 to 255.
    init?(hex: String) {
        guard hex.count == 9 else {
            return nil
        }
        var hex = hex
        hex.removeFirst()
        guard let binaryValue = Int64(hex, radix: 16) else {
            return nil
        }
        let r = Color.fromBinary(binaryValue, at: 0)
        let b = Color.fromBinary(binaryValue, at: 1)
        let g = Color.fromBinary(binaryValue, at: 2)
        let a = Color.fromBinary(binaryValue, at: 3)
        self.init(red: r, green: g, blue: b, opacity: a)
    }
}
