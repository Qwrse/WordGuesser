//
//  Kind.swift
//  WordGuesser
//
//  Created by dimss on 05.02.2026.
//

import Foundation

/// A semantic role for a `Code` value.
enum Kind: Equatable, CustomStringConvertible {
    /// A master code, optionally hidden from the player.
    case master(isHidden: Bool)
    /// The editable code for the current guess.
    case guess
    /// A previous guess together with its match result.
    case attempt([Match])
    /// An unrecognized kind loaded from storage.
    case unknown
    
    /// A stable string representation used for persistence.
    var description: String {
        switch self {
        case .master(let isHidden):
            return "master(\(isHidden))"
        case .guess:
            return "guess"
        case .attempt(let matches):
            let rawMatches = matches.map { $0.rawValue }.joined(separator: ",")
            return "attempt(\(rawMatches))"
        case .unknown:
            return "unknown"
        }
    }
    
    /// Creates a kind from its persisted string representation.
    init(_ string: String) {
        self = if string == "guess" {
            .guess
        } else if let isHidden: Bool = Kind.argument(from: string, prefix: "master(") {
            .master(isHidden: isHidden)
        } else if let matches: [Match] = Kind.argument(from: string, prefix: "attempt(") {
            .attempt(matches)
        } else {
            .unknown
        }
    }

    /// Returns the argument stored inside a persisted kind string.
    private static func argument<T: HasStringFallibleInitializer>(from string: String, prefix: String) -> T? {
        guard string.hasPrefix(prefix), string.hasSuffix(")") else {
            return nil
        }
        let argumentString = string[string.index(string.startIndex, offsetBy: prefix.count) ..<
                                    string.index(string.endIndex, offsetBy: -1)]
        return T(String(argumentString))
    }
}

/// A type that can be created from a stored string representation.
private protocol HasStringFallibleInitializer {
    /// Creates a value from `string` when possible.
    init?(_ string: String)
}


extension Bool: HasStringFallibleInitializer {
    /// Creates a Boolean from `"true"` or `"false"`.
    init?(_ string: String) {
        switch string {
        case "true":
            self = true
        case "false":
            self = false
        default:
            return nil
        }
    }
}

extension Array: HasStringFallibleInitializer where Element: HasStringFallibleInitializer {
    /// Creates an array from a comma-separated string.
    init?(_ string: String) {
        let splits = string.split(separator: ",")
        let convertedElements = splits.compactMap { Element(String($0)) }
        if convertedElements.count < splits.count {
            return nil
        } else {
            self = convertedElements
        }
    }
}

extension Match: HasStringFallibleInitializer {
    /// Creates a match from its raw value.
    init?(_ string: String) {
        for option in Match.allCases {
            if string == option.rawValue {
                self = option
                return
            }
        }
        return nil
    }
}
