//
//  Skip.swift
//
//
//  Created by Mateusz Kosikowski on 21/05/2024.
//

internal import SwiftCompilerPlugin
internal import SwiftDiagnostics
public import SwiftSyntax
internal import SwiftSyntaxBuilder
public import SwiftSyntaxMacros
@_spi(ExperimentalLanguageFeature) public import SwiftSyntaxMacros

///
/// A public structure representing a preamble macro called `Skip`.
/// This macro is used to skip the execution of test functions
/// (that start with the prefix "test".)
///
/// Usage: `@Skip`
///
@_spi(ExperimentalLanguageFeature)
public struct Skip: PreambleMacro {
    private static let macroName = "\(Self.self)"

    /// Generates the preamble code for the test body.
    ///
    /// - Parameters:
    ///   - _: The attribute syntax node representing the macro attribute.
    ///   - declaration: The declaration syntax node to which the macro is applied.
    ///   - _: The macro expansion context.
    /// - Throws: A `DiagnosticsError` if the macro cannot be applied to the provided declaration.
    ///             or there is incosistency detected.
    /// - Returns: An array of `CodeBlockItemSyntax` representing the expansion code for the macro.
    ///
    public static func expansion(
        of _: AttributeSyntax,
        providingPreambleFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
        in _: some MacroExpansionContext
    ) throws -> [CodeBlockItemSyntax] {
        // Check if the declaration is a function declaration
        guard let funcDecl = declaration.as(FunctionDeclSyntax.self) else {
            throw SwiftSyntaxMacros.MacroExpansionErrorMessage("@\(macroName) affects functions only.")
        }

        // Ensure the function name starts with "test"
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

        // Ensure the function has a throws specifier
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

        // Return the expansion code to skip the test
        return ["throw XCTSkip(\"⚠️ This test is ignored due to the effect of the @\(raw: macroName) macro.\")"]
    }
}
