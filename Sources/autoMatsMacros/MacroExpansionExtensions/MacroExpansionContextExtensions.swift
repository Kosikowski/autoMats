//
//  MacroExpansionContextExtensions.swift
//
//
//  Created by Mateusz Kosikowski on 27/05/2024.
//

internal import SwiftDiagnostics
internal import SwiftSyntaxMacros

extension MacroExpansionContext {
    func diagnose(_ diagnostics: [Diagnostic]) {
        for diagnostic in diagnostics {
            diagnose(diagnostic)
        }
    }
}
