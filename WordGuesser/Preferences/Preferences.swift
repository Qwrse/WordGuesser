//
//  Preferences.swift
//  WordGuesser
//
//  Created by dimss on 30/01/2026.
//

import SwiftUI


/// Environment access to the shared UI preferences.
extension EnvironmentValues {
    /// The shared UI preferences.
    @Entry var preferences = Preferences.shared
}

/// A shape style used to render pegs.
enum PegShape: String, CaseIterable {
    /// A circular peg.
    case circle = "Circle"
    /// A rounded rectangle peg.
    case roundedRectangle = "Rounded rectangle"
    /// A diamond peg.
    case diamond = "Diamond"

    /// A view that draws the peg shape.
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

/// Shared UI preferences for the game.
@Observable class Preferences {
    /// The color for exact matches.
    var exact: Color = .green
    /// The color for inexact matches.
    var inexact: Color = .yellow
    /// The color for non-matching pegs.
    var nomatch: Color = .graySelection
    /// The shape used for pegs.
    var pegShape: PegShape = .circle
    
    /// The shared preference store.
    static var shared = Preferences()
    
    /// Creates the default preferences and loads persisted values.
    private init() {
        load()
    }
    
    /// Saves the current preferences to `UserDefaults`.
    func save() {
        let defaults = UserDefaults.standard
        defaults.setColor(exact, forKey: "exact")
        defaults.setColor(inexact, forKey: "inexact")
        defaults.setColor(nomatch, forKey: "nomatch")
        defaults.set(pegShape.rawValue, forKey: "peg")
    }
    
    /// Loads persisted preferences into `self`.
    func load() {
        let defaults = UserDefaults.standard
        if let color = defaults.color(forKey: "exact") { exact = color }
        if let color = defaults.color(forKey: "inexact") { inexact = color }
        if let color = defaults.color(forKey: "nomatch") { nomatch = color }
        if let pegShapeRawValue = defaults.string(forKey: "peg"),
           let pegShape = PegShape(rawValue: pegShapeRawValue)
        {
            self.pegShape = pegShape
        }
    }
}

// MARK: - UserDefaults access Color Extensions
extension UserDefaults {
    /// Stores `value` as a hex string for `key`.
    func setColor(_ value: Color, forKey key: String) {
        set(value.hex, forKey: key)
    }
    
    /// Returns the color stored for `key`.
    func color(forKey key: String) -> Color? {
        guard let hex = string(forKey: key) else {
            return nil
        }
        return Color(hex: hex)
    }
}
