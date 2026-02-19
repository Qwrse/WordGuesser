//
//  Preferences.swift
//  WordGuesser
//
//  Created by dimss on 30/01/2026.
//

import SwiftUI


extension EnvironmentValues {
    /// The UI preferences.
    @Entry var preferences = Preferences.shared
}

/// `Peg` shape used in UI.
enum PegShape: String, CaseIterable {
    /// `Circle` shape.
    case circle = "Circle"
    /// `RoundedRectangle` shape with corner radius 10.
    case roundedRectangle = "Rounded rectangle"
    /// `Diamond` shape.
    case diamond = "Diamond"

    /// Access shape as a `View`.
    @ViewBuilder
    var shape: some View {
        switch self {
        case .circle:
            Circle()
        case .roundedRectangle:
            RoundedRectangle(cornerRadius: 10)
        case .diamond:
            Diamond()
        }
    }
}

/// User preferences to play the game.
@Observable class Preferences {
    /// The color for `Match.exact`.
    var exact: Color = .green
    /// The color for `Match.inexact`.
    var inexact: Color = .yellow
    /// The color for `Match.nomatch`.
    var nomatch: Color = .graySelection
    /// The shape of pegs in a `Code`.
    var peg: PegShape = .circle
    
    /// The unique instance of `Preferences`.
    static var shared = Preferences()
    
    /// Creates default `Preferences`.
    private init() {
        load()
    }
    
    /// Saves preferences to `UserDefaults`.
    func save() {
        let defaults = UserDefaults.standard
        defaults.setColor(exact, forKey: "exact")
        defaults.setColor(inexact, forKey: "inexact")
        defaults.setColor(nomatch, forKey: "nomatch")
        defaults.set(peg.rawValue, forKey: "peg")
    }
    
    /// Loads preferences from `UserDefaults` and updates `self`.
    func load() {
        let defaults = UserDefaults.standard
        if let color = defaults.color(forKey: "exact") { exact = color }
        if let color = defaults.color(forKey: "inexact") { inexact = color }
        if let color = defaults.color(forKey: "nomatch") { nomatch = color }
        if let pegRawValue = defaults.string(forKey: "peg"),
           let peg = PegShape(rawValue: pegRawValue)
        {
            self.peg = peg
        }
    }
}

// MARK: - UserDefaults access Color Extensions
extension UserDefaults {
    /// Sets the color of the specified key to a property list object.
    func setColor(_ value: Color, forKey key: String) {
        print("Set \(value.hex) for key \(key)")
        set(value.hex, forKey: key)
    }
    
    /// Returns the color associated with the specified key.
    func color(forKey key: String) -> Color? {
        guard let hex = string(forKey: key) else {
            return nil
        }
        print("Load \(hex) from key \(key)")
        return Color(hex: hex)
    }
}
