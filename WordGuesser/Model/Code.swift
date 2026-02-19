//
//  Code.swift
//  WordGuesser
//
//  Created by dimss on 18/01/2026.
//

import Foundation
import SwiftData

/// The sequence of `Peg`s.
@Model class Code {
    /// The `Kind` of current `Code`.
    var _kind: String = Kind.unknown.description
    /// The sequence of `Peg`s in current `Code`.
    var _pegs: [Peg]
    /// The time the code was created.
    var timestamp = Date.now
    /// The word in code.
    ///
    /// Equals to pegs.joined().
    /// It's stored property, due this value was stored in database.
    var _word: String
    
    /// Access `Kind` of current code.
    var kind: Kind {
        get { Kind(_kind) }
        set { _kind = newValue.description }
    }
    
    /// Access array of pegs in the code.
    var pegs: [Peg] {
        get { _pegs }
        set {
            _pegs = newValue
            _word = newValue.joined()
        }
    }
    
    /// Access word in the code.
    var word: String {
        get { _word }
        set {
            _word = newValue
            _pegs = newValue.map { String($0) }
        }
    }
    
    /// Creates code with `Kind` and pegs.
    init(kind: Kind, pegs: [Peg]) {
        _kind = kind.description
        _pegs = pegs
        _word = pegs.joined()
    }
    
    /// Creates `Code` with given `kind` and `length`, filled `Code.missingPeg`.
    convenience init(kind: Kind, length: Int) {
        self.init(kind: kind, pegs: Array(repeating: Code.missingPeg, count: length))
    }

    /// Creates `Code` from string `word`.
    convenience init(kind: Kind, word: String) {
        self.init(kind: kind, pegs: word.map { String($0) })
    }

    /// `Peg` which describes no choice.
    static let missingPeg: Peg = ""
    
    /// Generate `Code` with random pegs from `pegChoices`.
    ///
    /// Changes `pegs` to valid English word or replace `pegs` to `Code.missingPeg`.
    func randomize(from pegChoices: [Peg]) {
        if let word = Words.shared.random(length: pegs.count) {
            for (index, character) in word.enumerated() {
                if index < pegChoices.count {
                    pegs[index] = String(character)
                }
            }
        } else {
            pegs = Array(repeating: Code.missingPeg, count: pegs.count)
        }
    }
    
    /// Access whether `Code` should be hidden.
    var isHidden: Bool {
        switch kind {
        case .master(let isHidden): return isHidden
        default: return false
        }
    }
    
    /// Resets all `pegs` to `missingPeg`.
    func reset() {
        pegs = Array(repeating: Code.missingPeg, count: pegs.count)
    }
    
    /// Access matches for `kind` `attempt` and `nil` for another kinds.
    var matches: [Match]? {
        switch kind {
        case .attempt(let matches): return matches
        default: return nil
        }
    }

    /// Compares current code `against` `otherCode`.
    func match(against otherCode: Code) -> [Match] {
        var pegsToMatch = otherCode.pegs
        
        let backwardsExactMatches = pegs.indices.reversed().map { index in
            if pegsToMatch.count > index, pegsToMatch[index] == pegs[index] {
                pegsToMatch.remove(at: index)
                return Match.exact
            } else {
                return .nomatch
            }
        }
        let exactMatches = Array(backwardsExactMatches.reversed())
        return pegs.indices.map { index in
            if exactMatches[index] != .exact, let matchIndex = pegsToMatch.firstIndex(of: pegs[index]) {
                pegsToMatch.remove(at: matchIndex)
                return .inexact
            } else {
                return exactMatches[index]
            }
        }
    }
}
