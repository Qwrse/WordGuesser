//
//  WordGuesserApp.swift
//  WordGuesser
//
//  Created by dimss on 18/01/2026.
//

import SwiftUI
import SwiftData

/// The app entry point for WordGuesser.
@main
struct WordGuesserApp: App {
    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            GameChooser()
                .modelContainer(for: WordGuesser.self)
        }
    }
}
