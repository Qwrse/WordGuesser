//
//  MatchMarkers.swift
//  WordGuesser
//
//  Created by dimss on 18/01/2026.
//

import SwiftUI

/// The match value for `Peg`.
enum Match: String, CaseIterable {
    /// The exact match.
    case nomatch
    /// The inexact match, `Peg` is in a word, but on another position.
    case exact
    /// `Peg` doesn't occurs in compared word.
    case inexact
    
    /// Access `color` which used in the UI.
    var associatedColor: Color {
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
    
    /// Returns position in sorted order `nil`, `.nomatch`, `.inexact`, `.exact`.
    ///
    /// `Nil` represents there was no attempts for `Peg`.
    static func orderPosition(_ match: Match?) -> Int {
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
    
    static func bestMatch(_ match1: Match?, _ match2: Match?) -> Match? {
        if orderPosition(match1) > orderPosition(match2) {
            match1
        } else {
            match2
        }
    }
}
