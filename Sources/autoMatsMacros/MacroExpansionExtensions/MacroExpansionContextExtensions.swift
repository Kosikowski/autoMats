//
//  MacroExpansionContextExtensions.swift
//
//
//  Created by Mateusz Kosikowski on 27/05/2024.
//

internal import SwiftDiagnostics
internal import SwiftSyntaxMacros

extension MacroExpansionContext {
    /// Allows to add diagnosctics from an array of ``Diagnostic``
    /// - Parameter diagnostics: An array of Swift-Syntax Diagnostic objects
    func diagnose(_ diagnostics: [Diagnostic]) {
        for diagnostic in diagnostics {
            diagnose(diagnostic)
        }
    }
}
