//
//  Timer.swift
//  WordGuesser
//
//  Created by dimss on 01/02/2026.
//

import SwiftUI

/// The timer draws how long user has played the game.
struct Timer: View {
    // MARK: Data In
    /// The game model.
    let game: WordGuesser
    
    // MARK: - Body
    var body: some View {
        ElapsedTime(startTime: game.startTime, endTime: game.endTime, timeSpent: game.elapsedTime)
            .monospaced()
    }
}
