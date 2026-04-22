//
//  Code.swift
//  WordGuesser
//
//  Created by dimss on 18/01/2026.
//

import Foundation
import SwiftData

/// A persisted sequence of pegs used in a game.
@Model class Code {
    /// The stored representation of `kind`.
    var _kind: String = Kind.unknown.description
    /// The stored peg sequence.
    var _pegs: [Peg]
    /// The creation date of the code.
    var timestamp = Date.now
    /// The stored word representation of `_pegs`.
    var _word: String
    
    /// The semantic role of the code.
    var kind: Kind {
        get { Kind(_kind) }
        set { _kind = newValue.description }
    }
    
    /// The peg sequence.
    var pegs: [Peg] {
        get { _pegs }
        set {
            _pegs = newValue
            _word = newValue.joined()
        }
    }
    
    /// The peg sequence joined as a word.
    var word: String {
        get { _word }
        set {
            _word = newValue
            _pegs = newValue.map { String($0) }
        }
    }
    
    /// Creates a code with `kind` and `pegs`.
    init(kind: Kind, pegs: [Peg]) {
        _kind = kind.description
        _pegs = pegs
        _word = pegs.joined()
    }
    
    /// Creates a code filled with `missingPeg`.
    convenience init(kind: Kind, length: Int) {
        self.init(kind: kind, pegs: Array(repeating: Code.missingPeg, count: length))
    }

    /// Creates a code from `word`.
    convenience init(kind: Kind, word: String) {
        self.init(kind: kind, pegs: word.map { String($0) })
    }

    /// The placeholder used for an empty peg.
    static let missingPeg: Peg = ""
    
    /// Replaces the code with a random valid word of the current length.
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
    
    /// A Boolean value that indicates whether the code should be hidden.
    var isHidden: Bool {
        switch kind {
        case .master(let isHidden): return isHidden
        default: return false
        }
    }
    
    /// Replaces every peg with `missingPeg`.
    func reset() {
        pegs = Array(repeating: Code.missingPeg, count: pegs.count)
    }
    
    /// The stored matches when the code represents an attempt.
    var matches: [Match]? {
        switch kind {
        case .attempt(let matches): return matches
        default: return nil
        }
    }

    /// Returns the per-peg matches against `otherCode`.
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
