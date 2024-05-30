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

/// ### TestBodyAnalyser
///
/// `TestBodyAnalyser` is a `SyntaxVisitor` class designed to ensure rigorous testing
/// practices by analyzing test bodies for calls to the System Under Test (SUT).
/// It recursively searches through the test code to identify and register
/// all method and property calls made to the SUT using `DeclReferenceExprSyntax`.
/// This ensures that the SUT is actively being tested within the test case.
/// If no such calls are found, `TestBodyAnalyser` raises a diagnostic error to indicate
/// that the SUT is not adequately tested.
/// Additionally, it checks for and flags any usage of optional-try to promote test failure
/// on pottential error.
///
class TestBodyAnalyser: SyntaxVisitor {
    private var diagnostics: [Diagnostic] = []
    private var sutCalls: Set<String> = []
    private var sut = false

    /// This method is called when traversing the syntax tree and encountering an expression.
    override func visit(_ node: DeclReferenceExprSyntax) -> SyntaxVisitorContinueKind {
        let name = node.baseName.text
        if name == "sut" { // detects sut
            sut = true
        } else if sut {
            sutCalls.insert(name) // the next node after sut is a function or property
            sut = false
        } else {
            sut = false
        }
        return .visitChildren // making sure children are visited, e.g. sut.inSut.fuctionCall()
    }

    /// This method is called when traversing the syntax tree and encountering a try expression.
    override func visit(_ node: TryExprSyntax) -> SyntaxVisitorContinueKind {
        if node.questionOrExclamationMark?.text == "?" {
            let diagnostic = Diagnostic(
                node: Syntax(node),
                message: SwiftSyntaxMacros.MacroExpansionErrorMessage(
                    "Optional-try expressions should not be used in tests."
                ),
                fixIts: [
                    FixIt(
                        message: SwiftSyntaxMacros.MacroExpansionFixItMessage(
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
            diagnostics.append(diagnostic)
        }
        return .visitChildren
    }

    /// Analyzes a syntax tree to collect diagnostics and System Under Test (SUT) calls.
    ///
    /// - Parameters:
    ///   - tree: The syntax tree conforming to a `SyntaxProtocol` to be analyzed.
    /// - Returns: A tuple containing an array of diagnostics and a set of strings representing SUT calls.
    func analise(_ tree: some SyntaxProtocol) -> ([Diagnostic], Set<String>) {
        walk(tree)
        return (diagnostics, sutCalls)
    }
}
