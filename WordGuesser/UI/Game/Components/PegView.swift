//
//  PegView.swift
//  WordGuesser
//
//  Created by dimss on 19/01/2026.
//

import SwiftUI


/// A view that renders a single peg.
struct PegView: View {
    // MARK: Data In
    /// The peg text to display.
    let peg: Peg
    /// The shared UI preferences.
    @Environment(\.preferences) private var preferences

    // MARK: Data In
    /// The match result for the peg.
    let match: Match?

    // MARK: - Body
    var body: some View {
        pegShape
            .foregroundStyle(.clear)
            .overlay {
                Text(peg)
            }
            .background {
                if peg == Code.missingPeg {
                    pegBorder
                }
                let backgroundColor: Color = match?.color ?? .clear
                pegShape.foregroundStyle(backgroundColor)
            }
            .contentShape(Circle())
            .aspectRatio(1, contentMode: .fit)
    }
    
    /// The preferred peg shape.
    var pegShape: some View {
        preferences.pegShape.shape
    }
    
    /// The border drawn for an empty peg.
    @ViewBuilder
    var pegBorder: some View {
        switch preferences.pegShape {
        case .circle:
            Circle().stroke(Color.gray)
        case .roundedRectangle:
            RoundedRectangle(cornerRadius: PegSettings.cornerRadius).stroke(Color.gray)
        case .diamond:
            Diamond().stroke(.gray)
        }
    }
}

/// Layout values for `PegView`.
struct PegSettings {
    /// The corner radius used for rounded rectangle pegs.
    static let cornerRadius: CGFloat = 10
}

#Preview {
    PegView(peg: "A", match: .exact)
        .padding()
}
