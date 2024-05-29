//
//  TestBodyAnalyser.swift
//
//
//  Created by Mateusz Kosikowski on 23/05/2024.
//

internal import SwiftDiagnostics
internal import SwiftSyntax
internal import SwiftSyntaxMacroExpansion
internal import SwiftSyntaxMacros

class TestBodyAnalyser: SyntaxVisitor {
    private var diagnostics: [Diagnostic] = []
    private var sutCalls: Set<String> = []
    private var sut = false

    override func visit(_ node: DeclReferenceExprSyntax) -> SyntaxVisitorContinueKind {
        let name = node.baseName.text
        if name == "sut" {
            sut = true
        } else if sut {
            sutCalls.insert(name)
            sut = false
        } else {
            sut = false
        }
        return .visitChildren
    }

    override func visit(_ node: TryExprSyntax) -> SyntaxVisitorContinueKind {
        if node.questionOrExclamationMark?.text == "?" {
            let d = Diagnostic(
                node: Syntax(node),
                message: SwiftSyntaxMacroExpansion.MacroExpansionErrorMessage(
                    "Optional-try expressions should not be used in tests."
                ),
                fixIts: [
                    FixIt(
                        message: SwiftSyntaxMacroExpansion.MacroExpansionFixItMessage(
                            "remove '?'"
                        ),
                        changes: [
                            FixIt.Change.replace(
                                oldNode: Syntax(node),
                                newNode: Syntax(TryExprSyntax(expression: node.expression))
                            ),
                        ]
                    ),
                ]
            )
            diagnostics.append(d)
        }
        return .visitChildren
    }

    func analise(_ tree: some SyntaxProtocol) -> ([Diagnostic], Set<String>) {
        walk(tree)
        return (diagnostics, sutCalls)
    }
}
