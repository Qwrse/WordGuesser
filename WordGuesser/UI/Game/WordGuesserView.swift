//
//  WordGuesserView.swift
//  WordGuesser
//
//  Created by dimss on 18/01/2026.
//

import SwiftUI

/// A view that presents a playable WordGuesser game.
struct WordGuesserView: View {
    // MARK: Data In
    /// The shared word store.
    @Environment(\.words) private var words
    
    // MARK: Data Shared with Me
    /// The game being played.
    let game: WordGuesser
    
    // MARK: Data Owned by Me
    /// The selected peg index in the current guess.
    @State private var selectedPegIndex = 0
    /// The text checker used to validate guessed words.
    @State private var wordChecker = UITextChecker()
    /// A Boolean value that indicates whether the length chooser is shown.
    @State private var isChoosingNewGameLength = false
    
    // MARK: - Body
    var body: some View {
        VStack {
            if isChoosingNewGameLength {
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
    
    /// The main game content.
    var gameView: some View {
        Group {
            Timer(game: game)
            codes
            restartButton
            if !game.isOver {
                keyboardView
            }
        }
    }
    
    /// The stack of master, current, and attempted codes.
    var codes: some View {
        Group {
            codeView(for: game.masterCode)
            ScrollView {
                if !game.isOver {
                    codeView(for: game.guess)
                }
                ForEach(game.attempts) { attempt in
                    codeView(for: attempt)
                }
            }
        }
    }
    
    /// The keyboard used to edit and submit guesses.
    var keyboardView: some View {
        Keyboard(choices: game.choices) { peg in
            withAnimation {
                game.setGuessPeg(peg, at: selectedPegIndex)
                selectedPegIndex = (selectedPegIndex + 1) % game.codeLength
            }
        } onRemoveSelected: {
            withAnimation {
                game.guess.pegs[selectedPegIndex] = Code.missingPeg
                selectedPegIndex = (selectedPegIndex - 1 + game.codeLength) % game.codeLength
            }
        } onGuess: {
            withAnimation(.guess) {
                if wordChecker.isWord(game.guess.word) {
                    if game.attemptGuess() {
                        selectedPegIndex = 0
                    }
                }
            }
        }
    }
    
    /// A control that lets the player start a new game with a new length.
    var lengthChooser: some View {
        HStack(spacing: 16) {
            Text("Choose length of words:")
            ForEach(3...6, id: \.self) { length in
                Button("\(length)") {
                    isChoosingNewGameLength = false
                    game.selectLength(length)
                    selectedPegIndex = 0
                }
            }
        }
    }
        
    /// A button that restarts the current game.
    var restartButton: some View {
        Button("Restart", systemImage: "arrow.circlepath") {
            withAnimation {
                game.restart()
                selectedPegIndex = 0
            }
        }
    }
    
    /// Returns a code view for `code`.
    func codeView(for code: Code) -> some View {
        CodeView(code: code, selection: $selectedPegIndex)
    }
}

extension Animation {
    /// The animation used when submitting a guess.
    static let guess = Animation.bouncy
}

extension Color {
    /// Returns a neutral gray color with `brightness`.
    static func gray(_ brightness: CGFloat) -> Color {
        return Color(hue: 148/360, saturation: 0, brightness: brightness)
    }
    
    /// The fill color used to highlight the selected peg.
    static let graySelection = gray(0.85)
}

#Preview {
    WordGuesserView(game: WordGuesser())
}
