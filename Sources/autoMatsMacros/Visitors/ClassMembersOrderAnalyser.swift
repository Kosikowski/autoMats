//
//  ClassMembersOrderAnalyser.swift
//
//
//  Created by Mateusz Kosikowski on 27/05/2024.
//

internal import SwiftDiagnostics
internal import SwiftSyntax
internal import SwiftSyntaxMacroExpansion
internal import SwiftSyntaxMacros

class ClassMembersOrderAnalyser: SyntaxVisitor {
    private var diagnostics: [Diagnostic] = []
    private var lastMARKSection: String? = nil

    override func visit(_ decl: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
        findMarkComment(for: decl)
        if lastMARKSection != nil {
            diagnostics.append(Diagnostic(
                node: decl,
                message: SwiftSyntaxMacros.MacroExpansionErrorMessage("All variables should be declared at the beginning of the class.")
            ))
        }
        return .skipChildren
    }

    override func visit(_ decl: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        findMarkComment(for: decl)
        let components = decl.name.text.components(separatedBy: "_")
        if components.first == "test" {
            if
                let section = components[safe: 1],
                let lastMARKSection,
                section != lastMARKSection
            {
                diagnostics.append(Diagnostic(
                    node: decl,
                    message: SwiftSyntaxMacros.MacroExpansionErrorMessage("The \(decl.name.text) method must belong to a \"// MARK: - \(section) <optinoalComment>\" section.")
                ))
            }

        } else if
            let lastMARKSection,
            lastMARKSection != "helper"
        {
            diagnostics.append(Diagnostic(
                node: decl,
                message: SwiftSyntaxMacros.MacroExpansionErrorMessage("The \(decl.name.text) helper method must be in a \"// MARK: - helper methods\" section, or moved to a designated extension.")
            ))
        }
        return .skipChildren
    }

    func analise(_ tree: some SyntaxProtocol) -> [Diagnostic] {
        walk(tree)
        return diagnostics
    }

    // MARK: - helper methods

    private func findMarkComment(for decl: DeclSyntaxProtocol) {
        for trivia in decl.leadingTrivia.pieces {
            if
                case let TriviaPiece.lineComment(text) = trivia,
                text.contains("MARK:")
            {
                if !text.contains("// MARK: - ") {
                    let diagn = Diagnostic(
                        node: decl,
                        message: SwiftSyntaxMacros.MacroExpansionErrorMessage("The MARK comment should be formatted : \"// MARK: - `interfaceUderTest` `optional description`\"")
                    )
                    diagnostics.append(diagn)
                } else if let sectionaName = text.deletingPrefix("// MARK: - ").components(separatedBy: " ").first {
                    lastMARKSection = sectionaName
                }
            }
        }
    }
}
