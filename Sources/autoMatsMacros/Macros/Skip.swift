//
//  Skip.swift
//
//
//  Created by Mateusz Kosikowski on 21/05/2024.
//

internal import Foundation
internal import SwiftCompilerPlugin
internal import SwiftDiagnostics
internal import SwiftSyntax
internal import SwiftSyntaxBuilder
public import SwiftSyntaxMacros
@_spi(ExperimentalLanguageFeature) public import SwiftSyntaxMacros

@_spi(ExperimentalLanguageFeature)
public struct Skip: PreambleMacro {
    private static let macroName = "\(Self.self)"

    public static func expansion(
        of _: AttributeSyntax,
        providingPreambleFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
        in _: some MacroExpansionContext
    ) throws -> [CodeBlockItemSyntax] {
        guard let funcDecl = declaration.as(FunctionDeclSyntax.self) else {
            throw SwiftSyntaxMacros.MacroExpansionErrorMessage("@\(macroName) affects functions only.")
        }

        guard funcDecl.name.text.hasPrefix("test") else {
            throw DiagnosticsError(
                diagnostics: [
                    Diagnostic(
                        node: Syntax(declaration),
                        message: SwiftSyntaxMacros.MacroExpansionErrorMessage(
                            "@\(macroName) affects functions whose name starts with 'test'."
                        )
                    ),
                ]
            )
        }

        if funcDecl.signature.effectSpecifiers?.throwsClause?.throwsSpecifier == nil {
            let newEffects: FunctionEffectSpecifiersSyntax = if let existingEffects = funcDecl.signature.effectSpecifiers {
                existingEffects.with(\.throwsClause, ThrowsClauseSyntax(throwsSpecifier: .keyword(.throws)))
            } else {
                FunctionEffectSpecifiersSyntax(throwsClause: ThrowsClauseSyntax(throwsSpecifier: .keyword(.throws)))
            }

            let newSignature = funcDecl.signature.with(\.effectSpecifiers, newEffects)

            let diagnostic = Diagnostic(
                node: Syntax(funcDecl),
                message: SwiftSyntaxMacros.MacroExpansionErrorMessage(
                    "@\(macroName) can only be used with function that 'throws'."
                ),
                fixIts: [
                    FixIt(
                        message: SwiftSyntaxMacros.MacroExpansionFixItMessage(
                            "add 'throws'"
                        ),
                        changes: [
                            FixIt.Change.replace(
                                oldNode: Syntax(funcDecl.signature),
                                newNode: Syntax(newSignature)
                            ),
                        ]
                    ),
                ]
            )
            throw DiagnosticsError(diagnostics: [diagnostic])
        }

        return ["throw XCTSkip(\"⚠️ This test is ignored due to the effect of the @\(raw: macroName) macro.\")"]
    }
}
