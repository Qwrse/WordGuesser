//
//  CodeView.swift
//  WordGuesser
//
//  Created by dimss on 19/01/2026.
//

import SwiftUI

/// The `Code` view.
///
/// Supports all `Code` `Kind`s.
/// Details:
/// `Code.Kind.guess`: highlights chosen `Peg`.
/// `Code.Kind.attempt`: highlights exact, inexact and incorrect `Matches`.
/// `Code.Kind.master`: hide code behind `RoundedRectangles`.
/// `Code.Kind.unknown`: draws only `Pegs`.
struct CodeView: View {
    // MARK: Data In
    /// The `Code`.
    let code: Code
    /// The user preferences.
    @Environment(\.preferences) var preferences
    
    // MARK: Data Shared with Me
    /// The selection for `Code.Kind.guess` kind.
    @Binding var selection: Int
    
    // MARK: Data Owned by Me
    /// The namespace for matched geometry effect.
    @Namespace private var selectionNamespace
    
    /// Creates `CodeView` using `code` and optional `selection`.
    ///
    /// If `selection` is `nil`, selection will be 0.
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
                    .background {  // highlighting selected peg
                        if selection == index, code.kind == .guess {
                            preferences.peg.shape
                                .foregroundStyle(Selection.color)
                                .matchedGeometryEffect(id: "selection", in: selectionNamespace)
                        }
                    }
                    .overlay {  // hidden curve
                        preferences.peg.shape
                            .foregroundStyle(code.isHidden ? Color.gray : .clear)
                            .opacity(0.5)  // make opacity = 1 for production
                            .padding(Hiding.border)
                    }
                    .onTapGesture {  // change selection
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
    
    /// The selection settings view.
    struct Selection {
        /// The padding around selected `Peg`.
        static let border: CGFloat = 5
        /// The corner radius for selected `shape` at the background.
        static let cornerRadius: CGFloat = PegSettings.cornerRadius
        /// The color of selected `shape` at the background.
        static let color: Color = Color.graySelection
    }
    
    /// The hiding curve settings view.
    struct Hiding {
        /// The padding around hiding `Peg`.
        static let border: CGFloat = 5
    }
}

// Source - https://stackoverflow.com/a
// Posted by Nikita Kukushkin, modified by community. See post 'Timeline' for change history
// Retrieved 2026-01-29, License - CC BY-SA 4.0

extension Collection {
    // Returns the element at the specified index if it is within bounds, otherwise nil.
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
