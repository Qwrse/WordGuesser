//
//  WordGuesserView.swift
//  WordGuesser
//
//  Created by dimss on 18/01/2026.
//

import SwiftUI

/// The word guesser view.
struct WordGuesserView: View {
    // MARK: Data In
    /// The `Words` which was fetched.
    @Environment(\.words) var words
    
    // MARK: Data Shared with Me
    /// The WordGuesser model.
    let game: WordGuesser
    
    // MARK: Data Owned by Me
    /// The current selected `Peg`.
    @State private var selection: Int = 0
    /// English words checker.
    @State private var checker = UITextChecker()
    /// Whether new game is starting.
    ///
    /// Can sets to `true` when `WordGuesserView` is restarting.
    @State private var isStartingNewGame: Bool = false
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            if isStartingNewGame {
                lengthChooser
            } else {
                gameView
            }
        }
        .padding()
        .onChange(of: words.count, initial: true) {
             if game.attempts.count == 0 { // don’t disrupt a game in progress
                 if let word = words.random(length: game.masterCode.pegs.count) {
                     game.masterCode.word = word
                 }
             }
         }
        .onAppear {
            game.start()
        }
        .onDisappear(perform: game.finish)
    }
    
    /// The `game` view.
    ///
    /// Draws the game while it is not restarting.
    var gameView: some View {
        Group {
            Timer(game: game)
            codes
            restartButton
            if !game.isOver {
                keyBoardView
            }
        }
    }
    
    /// The `game.masterCode`, `game.guess` and `game.attempts` view.
    ///
    /// The view draws all codes in the `game`.
    var codes: some View {
        Group {
            view(for: game.masterCode)
            ScrollView {
                if !game.isOver {
                    view(for: game.guess)
                }
                ForEach(game.attempts) { attempt in
                    view(for: attempt)
                }
            }
        }
    }
    
    /// The `KeyBoard` view.
    var keyBoardView: some View {
        KeyBoard(choices: game.choices) { peg in
            withAnimation {
                game.setGuessPeg(peg, at: selection)
                selection = (selection + 1) % game.codeLength
            }
        } onRemoveSelected: {
            withAnimation {
                game.guess.pegs[selection] = Code.missingPeg
                selection = (selection - 1 + game.codeLength) % game.codeLength
            }
        } onGuess: {
            withAnimation(.guess) {
                if checker.isAWord(game.guess.word) {
                    if game.attemptGuess() {
                        selection = 0
                    }
                }
            }
        }
    }
    
    /// Draws the length chooser.
    ///
    /// The user can choose what length of `game.codeLength` it would play.
    var lengthChooser: some View {
        HStack(spacing: 16) {
            Text("Choose length of words:")
            ForEach(3...6, id: \.self) { length in
                Button("\(length)") {
                    isStartingNewGame = false
                    game.selectLength(length)
                    selection = 0
                }
            }
        }
    }
        
    /// The restart button.
    var restartButton: some View {
        Button("Restart", systemImage: "arrow.circlepath") {
            withAnimation {
                game.restart()
                selection = 0
            }
        }
    }
    
    /// The view for `Code` and `guessButton`.
    func view(for code: Code) -> some View {
        CodeView(code: code, selection: $selection)
    }
}

extension Animation {
    static let guess = Animation.bouncy
}

extension Color {
    static func gray(_ brightness: CGFloat) -> Color {
        return Color(hue: 148/360, saturation: 0, brightness: brightness)
    }
    
    static let graySelection = gray(0.85)
}

#Preview {
    WordGuesserView(game: WordGuesser())
}
