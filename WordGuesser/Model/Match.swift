//
//  MatchMarkers.swift
//  WordGuesser
//
//  Created by dimss on 18/01/2026.
//

import SwiftUI

/// A comparison result for a peg.
enum Match: String, CaseIterable {
    /// A peg that does not occur in the target word.
    case nomatch
    /// A peg in the correct position.
    case exact
    /// A peg that occurs in the target word at another position.
    case inexact
    
    /// The color used to render the match.
    var color: Color {
        let preferences = Preferences.shared
        return switch self {
        case .nomatch:
            preferences.nomatch
        case .exact:
            preferences.exact
        case .inexact:
            preferences.inexact
        }
    }
    
    /// Returns the ranking used to compare match quality.
    static func rank(of match: Match?) -> Int {
        guard let match else {
            return 0
        }
        switch match {
        case .nomatch:
            return 1
        case .inexact:
            return 2
        case .exact:
            return 3
        }
    }
    
    /// Returns the better of two optional matches.
    static func best(of lhs: Match?, and rhs: Match?) -> Match? {
        if rank(of: lhs) > rank(of: rhs) {
            lhs
        } else {
            rhs
        }
    }
}
