//
//  KeyBoard.swift
//  WordGuesser
//
//  Created by dimss on 19/01/2026.
//

import SwiftUI

/// A keyboard view for choosing pegs and submitting guesses.
struct Keyboard: View {
    // MARK: Data In
    /// The pegs to display together with their best known match.
    let choices: [(peg: Peg, bestMatch: Match?)]
    
    // MARK: Data Out Function
    /// The action called when the player chooses a peg.
    var onChoose: ((Peg) -> Void)?
    /// The action called when the player removes a peg.
    var onRemoveSelected: (() -> Void)?
    /// The action called when the player submits a guess.
    var onGuess: (() -> Void)?

    // MARK: - Body
    var body: some View {
        let charactersPerRow = [10, 9, 7]
        let rowOffsets = [0, 10, 19]
        VStack(spacing: KeyboardLayout.rowSpacing) {
            ForEach(charactersPerRow.indices, id: \.self) { rowIndex in
                let rowLength = charactersPerRow[rowIndex]
                HStack {
                    ForEach(0..<rowLength, id: \.self) { columnIndex in
                        let offset = rowOffsets[rowIndex] + columnIndex
                        let (peg, bestMatch) = choices[offset]
                        letterView(peg, bestMatch: bestMatch)
                    }
                    if rowIndex == 1 {
                        backspaceButton
                    }
                    if rowIndex == 2 {
                        guessButton
                    }
                }
            }
        }
        .aspectRatio(10/3, contentMode: .fit)
        .padding(.horizontal)
    }
    
    /// Returns a button for `peg`.
    func letterView(_ peg: Peg, bestMatch: Match?) -> some View {
        Button {
            onChoose?(peg)
        } label: {
            Text(peg)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(KeyLayout.aspectRatio, contentMode: .fit)
        .background {
            Circle()
                .foregroundStyle(bestMatch?.color ?? .clear)
        }
    }
    
    /// A button that removes the selected peg.
    var backspaceButton: some View {
        Button {
            onRemoveSelected?()
        } label: {
            Image(systemName: "delete.backward")
        }
        .padding(.leading, KeyLayout.ancillaryPadding)
    }
    
    /// A button that submits the current guess.
    var guessButton: some View {
        Button {
            onGuess?()
        } label: {
            Text("GUESS")
        }
        .padding(.leading, KeyLayout.ancillaryPadding)
    }
    
    /// Layout metrics for letter keys.
    struct KeyLayout {
        /// The aspect ratio for each key.
        static let aspectRatio: CGFloat = 1
        /// The padding around each key.
        static let padding: CGFloat = 8
        /// The leading padding for action keys.
        static let ancillaryPadding: CGFloat = 4
    }
    
    /// Layout metrics for the keyboard.
    struct KeyboardLayout {
        /// The spacing between rows.
        static let rowSpacing: CGFloat = 8
    }
}


#Preview {
    let game = WordGuesser()
    Keyboard(choices: game.choices)
}
