//
//  WordGuesser.swift
//  WordGuesser
//
//  Created by dimss on 18/01/2026.
//

import Foundation
import SwiftData

/// One element from `Code`, usually a character.
typealias Peg = String

/// Word guesser game model.
///
/// Secret code is a valid English word. All attempts must too be valid English words.
@Model class WordGuesser {
    /// The secret `Code`.
    @Relationship(deleteRule: .cascade) var masterCode: Code
    /// The current attempt.
    @Relationship(deleteRule: .cascade) var guess: Code
    /// The previous attempts.
    @Relationship(deleteRule: .cascade) var _attempts: [Code] = []
    /// The last attempt time.
    var lastAttemptTime: Date?
    /// The possible elements of `Code`.
    var pegChoices: [Peg]
    /// The amount of time user has played the game excluding last session.
    var elapsedTime: TimeInterval = 0
    /// The start time of last session.
    ///
    /// Set start time on view appear to represent an interval user has played the game.
    ///
    /// The start time can be `nil` in two cases:
    /// - Game hasn't ever started.
    /// - Game is paused.
    @Transient var startTime: Date?
    /// The end time of last session.
    ///
    /// The end time can `nil` in three cases:
    /// - Game hasn't ever started.
    /// - Game is started but isn't over.
    /// - Game is paused.
    var endTime: Date?
    /// The `true` if master code was guessed; `false` otherwise.
    var isOver: Bool = false
    
    /// Access all attempts in sorted order.
    ///
    /// Attempts are sorted by timestamp.
    var attempts: [Code] {
        get { _attempts.sorted { $0.timestamp > $1.timestamp } }
        set { _attempts = newValue }
    }

    /// Access all english characters in keyboard order.
    static var englishCharacters: [Peg] {
        "QWERTYUIOPASDFGHJKLZXCVBNM".map { String($0) }
    }
        
    /// Creates `WordGuesser` game with peg choices and code length.
    ///
    /// Arguments:
    /// - pegChoices are symbols which can be used in codes.
    /// - codeLength is the length for each code in the game.
    init(pegChoices: [Peg] = englishCharacters, codeLength: Int = 4) {
        self.pegChoices = pegChoices
        let masterCode = Code(kind: .master(isHidden: true), length: codeLength)
        masterCode.randomize(from: pegChoices)
        self.masterCode = masterCode
        guess = Code(kind: .guess, length: codeLength)
    }
    
    /// Access number of `pegs` in `masterCode`.
    var codeLength: Int {
        masterCode.pegs.count
    }
    
    /// Access the best `Match` for every `Peg`.
    ///
    /// Returns `(peg, nil)` if there wasn't attempt for this `peg`.
    /// Time complexity O(attempts.size * pegChoices.size).
    var choices: [(peg: Peg, bestMatch: Match?)] {
        var bestMatches: [Peg:Match] = [:]
        attempts.forEach { attempt in
            if let matches = attempt.matches {
                zip(attempt.pegs, matches).forEach { (peg, match) in
                    bestMatches[peg] = Match.bestMatch(match, bestMatches[peg])
                }
            }
        }
        return pegChoices.map { peg in
            (peg: peg, bestMatch: bestMatches[peg])
        }
    }
    
    /// Access last attempt if there is any;
    /// access `nil` otherwise.
    var lastAttempt: Code? {
        attempts.first
    }
    
    /// Restarts the game.
    ///
    /// Randomises `masterCode`; removes `attempts`; and clear `guess`.
    func restart() {
        selectLength(masterCode.pegs.count)
    }
    
    /// Selects code length and restarts the game.
    ///
    /// Randomises `masterCode`; removes `attempts`; and clear `guess`.
    /// - See `restart`.
    func selectLength(_ length: Int) {
        masterCode = Code(kind: .master(isHidden: true), length: length)
        masterCode.randomize(from: pegChoices)
        attempts = []
        guess = Code(kind: .guess, length: length)
        startTime = Date.now
        endTime = nil
        elapsedTime = .zero
    }

    /// Makes attempt to guess `masterCode`.
    ///
    /// Returns `true` if current `guess` doesn't contains `Code.missingPeg`;
    /// otherwise returns `false`.
    /// When returns `true` remembers and save `guess` to `self.attempts`.
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
    
    /// Sets `startTime` to `Date.now` if game isn't over.
    ///
    /// Use this method on view appear to updating timer.
    func start() {
        if !isOver {
            startTime = Date.now
        }
    }
    
    /// Finishes current session game.
    ///
    /// Updates `elapsedTime`;
    /// sets `startTime` and `endTime` to `nil`.
    func finish() {
        if let startTime {
            elapsedTime += (endTime ?? Date.now).timeIntervalSince(startTime)
        }
        startTime = nil
        endTime = nil
    }
    
    /// Sets `peg` `at` `index` in current `guess`.
    func setGuessPeg(_ peg: Peg, at index: Int) {
        guard guess.pegs.indices.contains(index) else { return }
        guess.pegs[index] = peg
    }

    // MARK: - For Testing or Preview only
    /// Makes attempt to guess `masterCode`.
    ///
    /// Returns `true` if `code` length equal to `codeLength`;
    /// otherwise returns `false`.
    /// When returns `true` remembers `code` to `self.attempts` and clears `guess`.
    func attemptGuess(word: String) -> Bool {
        guard word.count == codeLength else {
            return false
        }
        guess = Code(kind: .guess, word: word)
        return attemptGuess()
    }
    
    /// Calls `generateWord` `count` times and make attempts.
    func attemptGuess(count: Int, generateWord: () -> String?) {
        for _ in 0..<count {
            if let word = generateWord() {
                let _ = attemptGuess(word: word)
            }
        }
    }
}



extension WordGuesser: Comparable {
    /// Compares two `WordGuesser` games by `lastAttemptTime`.
    ///
    /// - Returns `true` if `lhs` last attempt was after `rhs` last attempt;
    /// `nils` goes first.
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
