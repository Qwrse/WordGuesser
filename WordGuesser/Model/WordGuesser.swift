//
//  WordGuesser.swift
//  WordGuesser
//
//  Created by dimss on 18/01/2026.
//

import Foundation
import SwiftData

/// A single code element, typically one character.
typealias Peg = String

/// A persisted WordGuesser game state.
@Model class WordGuesser {
    /// The secret code.
    @Relationship(deleteRule: .cascade) var masterCode: Code
    /// The editable current guess.
    @Relationship(deleteRule: .cascade) var guess: Code
    /// The stored attempts in persistence order.
    @Relationship(deleteRule: .cascade) var _attempts: [Code] = []
    /// The date of the most recent attempt.
    var lastAttemptTime: Date?
    /// The allowed peg values.
    var pegChoices: [Peg]
    /// The accumulated play time excluding the active session.
    var elapsedTime: TimeInterval = 0
    /// The start date of the active session, if any.
    @Transient var startTime: Date?
    /// The end date of the last completed session, if any.
    var endTime: Date?
    /// A Boolean value that indicates whether the game is over.
    var isOver: Bool = false
    
    /// The attempts sorted by most recent first.
    var attempts: [Code] {
        get { _attempts.sorted { $0.timestamp > $1.timestamp } }
        set { _attempts = newValue }
    }

    /// English letters in keyboard order.
    static var englishCharacters: [Peg] {
        "QWERTYUIOPASDFGHJKLZXCVBNM".map { String($0) }
    }
        
    /// Creates a game with `pegChoices` and `codeLength`.
    init(pegChoices: [Peg] = englishCharacters, codeLength: Int = 4) {
        self.pegChoices = pegChoices
        let masterCode = Code(kind: .master(isHidden: true), length: codeLength)
        masterCode.randomize(from: pegChoices)
        self.masterCode = masterCode
        guess = Code(kind: .guess, length: codeLength)
    }
    
    /// The number of pegs in each code.
    var codeLength: Int {
        masterCode.pegs.count
    }
    
    /// The best known match status for each available peg.
    var choices: [(peg: Peg, bestMatch: Match?)] {
        var bestMatches: [Peg: Match] = [:]
        attempts.forEach { attempt in
            if let matches = attempt.matches {
                zip(attempt.pegs, matches).forEach { (peg, match) in
                    bestMatches[peg] = Match.best(of: match, and: bestMatches[peg])
                }
            }
        }
        return pegChoices.map { peg in
            (peg: peg, bestMatch: bestMatches[peg])
        }
    }
    
    /// The most recent attempt, if any.
    var lastAttempt: Code? {
        attempts.first
    }
    
    /// Restarts the game using the current code length.
    func restart() {
        selectLength(masterCode.pegs.count)
    }
    
    /// Restarts the game with a new code length.
    func selectLength(_ length: Int) {
        masterCode = Code(kind: .master(isHidden: true), length: length)
        masterCode.randomize(from: pegChoices)
        attempts = []
        guess = Code(kind: .guess, length: length)
        startTime = Date.now
        endTime = nil
        elapsedTime = .zero
    }

    /// Commits the current guess when it is complete and unique.
    func attemptGuess() -> Bool {
        guard !guess.pegs.contains(Code.missingPeg) else {
            return false
        }
        guard !attempts.contains(where: { $0.pegs == guess.pegs }) else {
            return false
        }
        let attempt = Code(kind: .attempt(guess.match(against: masterCode)), pegs: guess.pegs)
        if attempt.pegs == masterCode.pegs {
            isOver = true
        }
        attempts.insert(attempt, at: 0)
        attempts = Array(attempts)
        lastAttemptTime = Date.now
        guess.reset()
        if isOver {
            endTime = Date.now
            masterCode.kind = .master(isHidden: false)
        }
        return true
    }
    
    /// Starts timing the current session if the game is active.
    func start() {
        if !isOver {
            startTime = Date.now
        }
    }
    
    /// Finishes the current session and updates `elapsedTime`.
    func finish() {
        if let startTime {
            elapsedTime += (endTime ?? Date.now).timeIntervalSince(startTime)
        }
        startTime = nil
        endTime = nil
    }
    
    /// Sets `peg` at `index` in the current guess.
    func setGuessPeg(_ peg: Peg, at index: Int) {
        guard guess.pegs.indices.contains(index) else { return }
        guess.pegs[index] = peg
    }

    // MARK: - For Testing or Preview only
    /// Replaces the current guess with `word` and submits it.
    func attemptGuess(word: String) -> Bool {
        guard word.count == codeLength else {
            return false
        }
        guess = Code(kind: .guess, word: word)
        return attemptGuess()
    }
    
    /// Repeats `generateWord` up to `count` times and submits each result.
    func attemptGuess(count: Int, generateWord: () -> String?) {
        for _ in 0..<count {
            if let word = generateWord() {
                let _ = attemptGuess(word: word)
            }
        }
    }
}



extension WordGuesser: Comparable {
    /// Returns whether `lhs` should sort before `rhs`.
    static func < (lhs: WordGuesser, rhs: WordGuesser) -> Bool {
        switch (lhs.lastAttemptTime, rhs.lastAttemptTime) {
        case (nil, nil):
            return false
        case (nil, _?):
            return true
        case (_?, nil):
            return false
        case (let lhsLastTry?, let rhsLastTry?):
            return lhsLastTry > rhsLastTry
        }
    }
}
