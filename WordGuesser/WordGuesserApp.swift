//
//  WordGuesserApp.swift
//  WordGuesser
//
//  Created by dimss on 18/01/2026.
//

import SwiftUI
import SwiftData

@main
struct WordGuesserApp: App {
    var body: some Scene {
        WindowGroup {
            GameChooser()
                .modelContainer(for: WordGuesser.self)
        }
    }
}
