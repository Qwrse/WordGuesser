//
//  AppSettings.swift
//  WordGuesser
//
//  Created by dimss on 29/01/2026.
//

import SwiftUI

/// The sheet with settings for the application.
struct AppSettings: View {
    // MARK: Data Shared with Me
    /// The UI preferences.
    @Bindable var preferences = Preferences.shared

    // MARK: - Body
    var body: some View {
        Form {
            ColorPicker("Exact color", selection: $preferences.exact, supportsOpacity: false)
            ColorPicker("Inexact color", selection: $preferences.inexact, supportsOpacity: false)
            ColorPicker("No match color", selection: $preferences.nomatch, supportsOpacity: false)
            Picker("Peg shape", selection: $preferences.peg) {
                ForEach(PegShape.allCases, id: \.self) { shape in
                    Text(shape.rawValue).tag(shape)
                }
            }
        }
        .onDisappear {
            preferences.save()
        }
    }
}

#Preview {
    @Previewable var preferences = Preferences.shared
    
    AppSettings(preferences: preferences)
        .onChange(of: preferences.exact) {
            print("Changed exact color to \(Preferences.shared.exact)")
        }
}
