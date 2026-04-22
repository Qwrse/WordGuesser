//
//  Words.swift
//  CodeBreaker
//
//  Created by CS193p Instructor on 4/16/25.
//

import SwiftUI

/// Environment access to the shared word store.
extension EnvironmentValues {
    /// The shared word store.
    @Entry var words = Words.shared
}

/// A store that loads valid words by length.
@Observable
class Words {
    /// The loaded words keyed by word length.
    private var words = Dictionary<Int, Set<String>>()

    /// The shared word store.
    static let shared =
        Words(from: URL(string: "https://web.stanford.edu/class/cs193p/common.words"))

    /// Creates a word store that loads from `url`.
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
    
    /// The total number of loaded words.
    var count: Int {
        words.values.reduce(0) { $0 + $1.count }
    }
    
    /// Returns a Boolean value that indicates whether `word` exists.
    func contains(_ word: String) -> Bool {
        words[word.count]?.contains(word.uppercased()) == true
    }

    /// Returns a random word with `length`.
    func random(length: Int) -> String? {
        let word = words[length]?.randomElement()
        if word == nil {
            print("Words could not find a random word of length \(length)")
        }
        return word
    }
}

extension UITextChecker {
    /// Returns a Boolean value that indicates whether `word` is an English word.
    func isWord(_ word: String) -> Bool {
        Words.shared.contains(word)
    }
}
