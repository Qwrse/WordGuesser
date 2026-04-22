//
//  Timer.swift
//  WordGuesser
//
//  Created by dimss on 01/02/2026.
//

import SwiftUI

/// A view that displays the elapsed play time for a game.
struct Timer: View {
    // MARK: Data In
    /// The game to time.
    let game: WordGuesser
    
    // MARK: - Body
    var body: some View {
        ElapsedTime(startTime: game.startTime, endTime: game.endTime, elapsedTime: game.elapsedTime)
            .monospaced()
    }
}
