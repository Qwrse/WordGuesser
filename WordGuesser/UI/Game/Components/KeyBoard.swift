//
//  KeyBoard.swift
//  WordGuesser
//
//  Created by dimss on 19/01/2026.
//

import SwiftUI

/// The keyboard with `Pegs`.
struct KeyBoard: View {
    // MARK: Data In
    /// `Pegs` to choose and their the best `match` score.
    let choices: [(peg: Peg, bestMatch: Match?)]
    
    // MARK: Data Out Function
    /// The action which calls on choose.
    var onChoose: ((Peg) -> Void)?
    /// The action which calls when removes selected `peg`.
    var onRemoveSelected: (() -> Void)?
    /// The action which calls on guess.
    var onGuess: (() -> Void)?

    // MARK: - Body
    var body: some View {
        let charactersPerRow = [10, 9, 7]
        let offsetPerRow = [0, 10, 19]
        VStack(spacing: KeyBoardShape.rowsSpacing) {
            ForEach(charactersPerRow.indices, id: \.self) { rowIndex in  // keyboard row
                let rowLength = charactersPerRow[rowIndex]
                HStack {
                    ForEach(0..<rowLength, id: \.self) { columnIndex in  // keyboard letter
                        let offset = offsetPerRow[rowIndex] + columnIndex
                        let (peg, bestMatch) = choices[offset]
                        letterView(peg, bestMatch: bestMatch)
                    }
                    if rowIndex == 1 {
                        backSpaceButton
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
    
    /// Returns `Peg` view in keyboard.
    func letterView(_ peg: Peg, bestMatch: Match?) -> some View {
        Button {
            onChoose?(peg)
        } label: {
            Text(peg)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(LetterShape.aspectRatio, contentMode: .fit)
        .background {
            Circle()
                .foregroundStyle(bestMatch?.associatedColor ?? .clear)
        }
    }
    
    /// The button which removes last symbol.
    ///
    /// The last button in the second line in keyboard.
    var backSpaceButton: some View {
        Button {
            onRemoveSelected?()
        } label: {
            Image(systemName: "delete.backward")
        }
        .padding(.leading, LetterShape.ancillaryPadding)
    }
    
    /// The guess button.
    ///
    /// The last button in the third line in keyboard.
    var guessButton: some View {
        Button {
            onGuess?()
        } label: {
            Text("GUESS")
        }
        .padding(.leading, LetterShape.ancillaryPadding)
    }
    
    /// Settings for letter shape layout.
    struct LetterShape {
        /// The aspect ratio for every letter.
        static let aspectRatio: CGFloat = 1
        /// The padding around every letter.
        static let padding: CGFloat = 8
        /// The padding on `guessButton` and `backSpaceButton` on the left edge.
        static let ancillaryPadding: CGFloat = 4
    }
    
    /// Settings for keyboard shape layout.
    struct KeyBoardShape {
        /// The spacing between rows in the keyboard.
        static let rowsSpacing: CGFloat = 8
    }
}


#Preview {
    let game = WordGuesser()
    KeyBoard(choices: game.choices)
}
