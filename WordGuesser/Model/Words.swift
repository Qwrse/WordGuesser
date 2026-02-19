//
//  Words.swift
//  CodeBreaker
//
//  Created by CS193p Instructor on 4/16/25.
//

import SwiftUI

/// Extends environment for `Words`.
extension EnvironmentValues {
    /// `Words` fetcher.
    @Entry var words = Words.shared
}

/// The fetcher words by url.
@Observable
class Words {
    /// The words storage. Access `Set` of words by length.
    private var words = Dictionary<Int, Set<String>>()

    /// The unique instance of `Words`.
    static let shared =
        Words(from: URL(string: "https://web.stanford.edu/class/cs193p/common.words"))

    /// Creates fetcher `from` `url`.
    private init(from url: URL? = nil) {
        words[3]?.insert("KEY")
        words[4]?.insert("MOON")
        words[5]?.insert("QUEUE")
        words[6]?.insert("POWDER")
        Task {
            var _words = [Int:Set<String>]()
            if let url {
                do {
                    for try await word in url.lines {
                        _words[word.count, default: Set<String>()].insert(word.uppercased())
                    }
                } catch {
                    print("Words could not load words from \(url): \(error)")
                }
            }
            words = _words
            if count > 0 {
                print("Words loaded \(count) words from \(url?.absoluteString ?? "nil")")
            }
        }
    }
    
    /// Access total number of words.
    var count: Int {
        words.values.reduce(0) { $0 + $1.count }
    }
    
    /// Returns `true` if `word` exists; `false` otherwise.
    func contains(_ word: String) -> Bool {
        words[word.count]?.contains(word.uppercased()) == true
    }

    /// Returns random word given `length` from storage.
    func random(length: Int) -> String? {
        let word = words[length]?.randomElement()
        if word == nil {
            print("Words could not find a random word of length \(length)")
        }
        return word
    }
}

extension UITextChecker {
    /// Returns true if `word` is a correct English word.
    func isAWord(_ word: String) -> Bool {
        rangeOfMisspelledWord(
            in: word,
            range: NSRange(location: 0, length: word.utf16.count),
            startingAt: 0,
            wrap: false,
            language: "en_US"
        ).location == NSNotFound
    }
}
