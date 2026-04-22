//
//  CodeView.swift
//  WordGuesser
//
//  Created by dimss on 19/01/2026.
//

import SwiftUI

/// A view that renders a `Code`.
struct CodeView: View {
    // MARK: Data In
    /// The code to display.
    let code: Code
    /// The shared UI preferences.
    @Environment(\.preferences) private var preferences
    
    // MARK: Data Shared with Me
    /// The selected peg index for guess codes.
    @Binding var selection: Int
    
    // MARK: Data Owned by Me
    /// The namespace used by the selection highlight animation.
    @Namespace private var selectionNamespace
    
    /// Creates a code view for `code`.
    init(code: Code, selection: Binding<Int>? = nil) {
        self.code = code
        self._selection = selection ?? .constant(0)
    }
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: 0) {
            ForEach(code.pegs.indices, id: \.self) { index in
                PegView(peg: code.pegs[index], match: code.matches?[safe: index])
                    .padding(Selection.border)
                    .background {
                        if selection == index, code.kind == .guess {
                            preferences.pegShape.shape
                                .foregroundStyle(Selection.color)
                                .matchedGeometryEffect(id: "selection", in: selectionNamespace)
                        }
                    }
                    .overlay {
                        preferences.pegShape.shape
                            .foregroundStyle(code.isHidden ? Color.gray : .clear)
                            .opacity(0.5)
                            .padding(Hiding.border)
                    }
                    .onTapGesture {
                        print("clicked \(index)")
                        if code.kind == .guess {
                            withAnimation {
                                selection = index
                            }
                        }
                    }
            }
        }
    }
    
    /// Layout values for the selection highlight.
    struct Selection {
        /// The padding around the selected peg.
        static let border: CGFloat = 5
        /// The corner radius for the highlight.
        static let cornerRadius: CGFloat = PegSettings.cornerRadius
        /// The highlight color.
        static let color: Color = Color.graySelection
    }
    
    /// Layout values for the hidden-code overlay.
    struct Hiding {
        /// The padding around the hidden overlay.
        static let border: CGFloat = 5
    }
}

// Source - https://stackoverflow.com/a
// Posted by Nikita Kukushkin, modified by community. See post 'Timeline' for change history
// Retrieved 2026-01-29, License - CC BY-SA 4.0

extension Collection {
    /// Returns the element at `index` when it is within bounds.
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    VStack {
        let word = "ABCD"
        CodeView(code: Code(kind: .guess, word: word), selection: .constant(0))
        CodeView(code: Code(kind: .attempt([.exact, .nomatch, .nomatch, .inexact]), word: word))
        CodeView(code: Code(kind: .master(isHidden: true), word: word))
        CodeView(code: Code(kind: .master(isHidden: false), word: word))
    }
}
