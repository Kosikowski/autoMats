//
//  StringExtensions.swift
//
//
//  Created by Mateusz Kosikowski on 19/05/2024.
//

extension String {
    /// Deletes the prefix from the string if it matches the given prefix.
    ///
    /// - Parameters:
    ///   - prefix: The prefix to be removed.
    /// - Returns: A new string with the prefix removed if it matches, otherwise the original string.
    func deletingPrefix(_ prefix: String) -> String {
        guard hasPrefix(prefix) else { return self }
        return String(dropFirst(prefix.count))
    }

    /// Deletes the suffix from the string if it matches the given suffix.
    ///
    /// - Parameters:
    ///   - suffix: The suffix to be removed.
    /// - Returns: A new string with the suffix removed if it matches, otherwise the original string.
    func deletingSuffix(_ suffix: String) -> String {
        guard hasSuffix(suffix) else { return self }
        return String(dropLast(suffix.count))
    }
}
