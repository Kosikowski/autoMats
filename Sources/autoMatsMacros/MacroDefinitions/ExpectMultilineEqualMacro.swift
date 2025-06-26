// ExpectMultilineEqualMacro.swift
// Macro for expectMultilineEqual

import SwiftSyntax
import SwiftSyntaxBuilder
public import SwiftSyntaxMacros

/// Simple error wrapper for macro expansion errors
enum MacroExpansionError: Error {
    case message(String)
}

public struct ExpectMultilineEqualMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in _: some MacroExpansionContext
    ) throws -> ExprSyntax {
        let args = Array(node.arguments)
        guard args.count >= 2 else {
            throw MacroExpansionError.message("#expectMultilineEqual requires at least 2 arguments: actual and expected.")
        }
        let actual = args[0].expression
        let expected = args[1].expression
        let trimWhitespace = args.count > 2 ? args[2].expression : ExprSyntax("false")
        let sourceLocation = ExprSyntax(".init(fileID: #fileID, line: #line)")

        return ExprSyntax("__expectMultilineEqual(\(actual), \(expected), trimWhitespace: \(trimWhitespace), sourceLocation: \(sourceLocation))")
    }
}
