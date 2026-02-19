//
//  GameSummary.swift
//  WordGuesser
//
//  Created by dimss on 28/01/2026.
//

import SwiftUI

/// The `View` draws summarisation of `WordGuesser` game.
struct GameSummary: View {
    // MARK: Data In
    /// The `game` to summarise.
    let game: WordGuesser
    
    // MARK: - body

    var body: some View {
        VStack(alignment: .leading) {
            Text("Words length: \(game.codeLength)")
            Text("^[\(game.attempts.count) attempt](inflect: true)")
            Timer(game: game)
            let lastTry = game.lastAttempt ?? Code(kind: .attempt([]), length: game.codeLength)
            HStack {
                Text("Last attempt:")
                CodeView(code: lastTry)
                    .aspectRatio(CGFloat(game.codeLength), contentMode: .fit)
                    .frame(maxHeight: LastTry.maxHeight)
            }
        }
    }
    
    /// The settings for layout of last attempt.
    struct LastTry {
        /// The maximum height for `Code` preview.
        static let maxHeight: CGFloat = 40
    }
}

#Preview {
    @Previewable @State var game1 = WordGuesser(codeLength: 3)
    let _ = game1.attemptGuess(word: "SUM")
    
    let games = [game1,
                 WordGuesser(codeLength: 4),
                 WordGuesser(codeLength: 5),
                 WordGuesser(codeLength: 6)]
    
    List(games) { game in
        GameSummary(game: game)
    }
    .listStyle(.plain)
}
