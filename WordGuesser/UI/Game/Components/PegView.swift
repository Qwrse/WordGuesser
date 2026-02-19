//
//  PegView.swift
//  WordGuesser
//
//  Created by dimss on 19/01/2026.
//

import SwiftUI


/// The `Peg` view.
struct PegView: View {
    // MARK: Data In
    /// The input `Peg`.
    let peg: Peg
    /// UI preferences.
    @Environment(\.preferences) var preferences

    // MARK: Data In
    /// The `Match` current `peg` against correct `peg`.
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
                let backgroundColor: Color = match?.associatedColor ?? .clear
                pegShape.foregroundStyle(backgroundColor)
            }
            .contentShape(Circle())
            .aspectRatio(1, contentMode: .fit)
    }
    
    /// The shape of peg.
    var pegShape: some View {
        preferences.peg.shape
    }
    
    /// The border of preferred peg shape.
    @ViewBuilder
    var pegBorder: some View {
        switch preferences.peg {
        case .circle:
            Circle().stroke(Color.gray)
        case .roundedRectangle:
            RoundedRectangle(cornerRadius: PegSettings.cornerRadius).stroke(Color.gray)
        case .diamond:
            Diamond().stroke(.gray)
        }
    }
}

/// The settings for peg view.
struct PegSettings {
    /// The corner radius for `Peg` shape in case when it is `Preferences.roundedRectangle`.
    ///
    /// If preferred shape is `Circle` the value is ignored.
    static let cornerRadius: CGFloat = 10
}

#Preview {
    PegView(peg: "A", match: .exact)
        .padding()
}
