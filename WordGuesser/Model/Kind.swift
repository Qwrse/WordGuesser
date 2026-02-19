//
//  Kind.swift
//  WordGuesser
//
//  Created by dimss on 05.02.2026.
//

import Foundation

/// Kind of `Code`.
///
/// Kind has also string representation. There are formats for all cases
/// of `Kind`:
/// - .master: "master".
/// - .guess: "guess".
/// - .attempt: "attempts(match1.rawValue,match2.rawValue,...)" without spaces and comma at the end.
/// - .unknown: "unknown".
enum Kind: Equatable, CustomStringConvertible {
    /// The secret `Code`.
    case master(isHidden: Bool)
    /// Current attempt's `Code`.
    case guess
    /// Previous attempt.
    case attempt([Match])
    /// Unknown kind.
    case unknown
    
    /// Access string representation of `self`.
    var description: String {
        switch self {
        case .master(let isHidden):
            return "master(\(isHidden))"
        case .guess:
            return "guess"
        case .attempt(let attempts):
            let attemptsStr = attempts.map { $0.rawValue }.joined(separator: ",")
            return "attempt(\(attemptsStr))"
        case .unknown:
            return "unknown"
        }
    }
    
    /// Creates `Kind` from string representation.
    init(_ string: String) {
        self = if string == "guess" {
            .guess
        } else if let isHidden: Bool = Kind.argument(from: string, prefix: "master(") {
            .master(isHidden: isHidden)
        } else if let attempts: [Match] = Kind.argument(from: string, prefix: "attempt(") {
            .attempt(attempts)
        } else {
            .unknown
        }
    }

    /// Tries to create `T` from string representation.
    ///
    /// The string should has the format "prefix(argument)".
    private static func argument<T: HasStringFallibleInitializer>(from string: String, prefix: String) -> T? {
        guard string.hasPrefix(prefix), string.hasSuffix(")") else {
            return nil
        }
        let argumentString = string[string.index(string.startIndex, offsetBy: prefix.count) ..<
                                    string.index(string.endIndex, offsetBy: -1)]
        return T(String(argumentString))
    }
}

/// The protocol for types which has fallible initialiser from `String`.
private protocol HasStringFallibleInitializer {
    /// Tries to create type from `String`.
    init?(_ string: String)
}


extension Bool: HasStringFallibleInitializer {
    /// Tries to creates `Bool` from `String`.
    ///
    /// Converts "true" to true and "false" to false.
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
    /// Tries to create `Array` from `String`.
    ///
    /// String should be in format "arg1,arg2,arg3,..." without spaces and comma at the end.
    ///
    /// The result is succeed if all arguments successful converted to `Element`.
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
    /// Tries to create `Match` from `String`.
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
