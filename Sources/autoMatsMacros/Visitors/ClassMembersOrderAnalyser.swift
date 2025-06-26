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

/// ### ClassMembersOrderAnalyser
/// `ClassMembersOrderAnalyser` is a `SyntaxVisitor` subclass responsible for analyzing
/// the order and organization of class members within a `XCTestCase` code.
///
/// The class tracks the presence and placement of "// MARK: - " comments to ensure
/// that member sections are properly delineated. It verifies that variables are
/// declared before functions and that test methods are grouped under appropriate sections.
/// Additionally, it detects any deviations from the expected format of "// MARK: - " comments.
///
/// The analysis results in a collection of diagnostics, highlighting any violations
/// of the defined conventions.
///
class ClassMembersOrderAnalyser: SyntaxVisitor {
    private var diagnostics: [Diagnostic] = []
    private var lastMARKSection: String? = nil
    private var seenFunction = false

    /// Overrides the `visit` method in `SyntaxVisitor` to handle variable declaration syntax nodes
    /// during syntax tree traversal.
    ///
    /// This method identifies variable declarations and checks whether the variable is declared before
    /// any functions.
    /// If the variable declaration violates these conventions, a diagnostic error is added to the list of diagnostics.
    ///
    /// - Parameters:
    ///   - decl: The `VariableDeclSyntax` node representing the variable declaration being visited.
    /// - Returns: A `SyntaxVisitorContinueKind` indicating whether to continue visiting the children of the current node.
    override func visit(_ decl: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
        findMarkComment(for: decl)
        if lastMARKSection != nil || seenFunction {
            diagnostics.append(Diagnostic(
                node: decl,
                message: SwiftSyntaxMacros.MacroExpansionErrorMessage("All variables should be declared at the beginning of the class.")
            ))
        }
        return .skipChildren
    }

    ///
    /// This method identifies function declarations within the class and enforces specific
    /// conventions related to their placement and grouping. It checks whether the function
    /// is a test method or a helper method based on naming conventions.
    ///
    /// For test methods,
    /// it verifies that they belong to the correct "// MARK: - " section, ensuring proper
    /// organization within the test class.
    ///
    /// For helper methods, it ensures they are either within the "// MARK: - helper methods"
    /// section or moved to a designated extension.
    ///
    /// - Parameters:
    ///   - decl: The `FunctionDeclSyntax` node representing the function declaration being visited.
    /// - Returns: A `SyntaxVisitorContinueKind` indicating whether to continue visiting the children
    /// of the current node.
    override func visit(_ decl: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        findMarkComment(for: decl)
        seenFunction = true
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

    // Searches for "// MARK:" comments preceding a declaration within the source code.
    ///
    /// This method examines the leading trivia of the declaration syntax node to identify
    /// "// MARK: - " comments. It checks whether the "// MARK: - " comment follows the
    /// expected format, which includes the section name and an optional description
    /// separated by hyphens. If the "// MARK: - " comment is not formatted correctly,
    /// a diagnostic error is added to the list of diagnostics. Additionally, it extracts
    /// the name of the section from the "// MARK: - <name>" comment and updates the
    /// `lastMARKSection` property accordingly.
    ///
    /// - Parameter decl: The declaration syntax node for which to find the preceding
    /// "// MARK:" comment.
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
