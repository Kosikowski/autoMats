//
//  expectMultilineEqual.swift
//  autoMats
//
//  Created by Mateusz Kosikowski on 26/06/2025.
//

import Testing
import XCTest

/// Compares two multi-line strings line-by-line, failing on the first mismatch with detailed diagnostics.
/// - Parameters:
///   - actual: The actual string output (e.g., generated code).
///   - expected: The expected string output.
///   - trimWhitespace: If true, trims leading/trailing whitespace before comparison.
///   - file: The file where the expectation is called (for test diagnostics).
///   - line: The line where the expectation is called (for test diagnostics).
func expectMultilineEqual(
    _ actual: String,
    _ expected: String,
    trimWhitespace: Bool = false,
    sourceLocation: SourceLocation = #_sourceLocation
) {
    let actualLines = actual.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
    let expectedLines = expected.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)

    // Check for line count mismatch first
    if actualLines.count != expectedLines.count {
        let message = """
        Line count mismatch.
        Expected: \(expectedLines.count) lines
        Actual:   \(actualLines.count) lines
        Actual Lines: \(actual)
        """
        #expect(Bool(false), Comment(rawValue: message), sourceLocation: sourceLocation)

        return
    }

    // Compare lines
    for (idx, (actualLine, expectedLine)) in zip(actualLines, expectedLines).enumerated() {
        let actualToCompare = trimWhitespace ? actualLine.trimmingCharacters(in: .whitespaces) : actualLine
        let expectedToCompare = trimWhitespace ? expectedLine.trimmingCharacters(in: .whitespaces) : expectedLine

        if actualToCompare != expectedToCompare {
            // Provide context: show up to 2 lines before and after the mismatch
            let startIdx = max(0, idx - 2)
            let endIdx = min(actualLines.count, idx + 3)
            let actualContext = actualLines[startIdx ..< endIdx].map { "Actual:   \($0)" }.joined(separator: "\n")
            let expectedContext = expectedLines[startIdx ..< endIdx].map { "Expected: \($0)" }.joined(separator: "\n")

            let message = """
            Line \(idx + 1) mismatch.
            Expected: \(expectedToCompare)
            Actual:   \(actualToCompare)
            Source Location: \(sourceLocation.line) [\(sourceLocation.fileID)]
            Context (lines \(startIdx + 1)-\(endIdx)):
            \(expectedContext)
            ---
            \(actualContext)
            """
            #expect(Bool(false), Comment(rawValue: message), sourceLocation: sourceLocation)
            return
        }
    }
}
