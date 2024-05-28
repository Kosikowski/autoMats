//
//  CleanTest.swift
//
//
//  Created by Mateusz Kosikowski on 27/05/2024.
//

import Foundation
internal import SwiftDiagnostics
public import SwiftSyntax
internal import SwiftSyntaxMacroExpansion
public import SwiftSyntaxMacros

public struct CleanTest: MemberAttributeMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        guard
            let decl = declaration.memberBlock.members.first?.decl,
            decl.description == member.description
        else {
            return []
        }

        if declaration.isExtensionDecl {
            validateExtensionDeclaration(declaration.as(ExtensionDeclSyntax.self)!, in: context)
        } else if declaration.isClassDecl {
            validateClassDeclaration(declaration.as(ClassDeclSyntax.self)!, in: context)
        } else {
            context.diagnose(Diagnostic(
                node: node,
                message: SwiftSyntaxMacroExpansion.MacroExpansionErrorMessage("@CleanTest can only be used in class declarations subclassing XCTestCase, or extensions.")
            ))
        }
        return []
    }

    // MARK: - validation

    static func validateExtensionDeclaration(
        _ declaration: ExtensionDeclSyntax,
        in context: some MacroExpansionContext
    ) {
        validateTypeName(of: declaration, in: context)
        let _ = declaration.functions.map {
            validateFunctionName(of: $0, in: context)
        }
        validateMembersOrder(of: declaration, in: context)
    }

    static func validateClassDeclaration(
        _ declaration: ClassDeclSyntax,
        in context: some MacroExpansionContext
    ) {
        validateTypeName(of: declaration, in: context)
        validateFileName(of: declaration, context: context)
        validateInheritanceClause(of: declaration, in: context)
        validateSutDeclaration(of: declaration, in: context)

        _ = declaration.functions.map {
            validateFunctionName(of: $0, in: context)
        }

        validateMembersOrder(of: declaration, in: context)
    }

    // MARK: -

    static func validateTypeName(
        of declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) {
        guard
            let name = declaration.typeName,
            !name.hasSuffix("Tests")
        else {
            return
        }

        context.diagnose(
            Diagnostic(
                node: declaration,
                message: SwiftSyntaxMacroExpansion.MacroExpansionErrorMessage("\(name) name must end with \"Tests\".")
            )
        )
    }

    static func validateInheritanceClause(
        of declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) {
        guard declaration.inheritanceClause?.inheritanceTypeNames.contains("XCTestCase") == false else {
            return
        }

        guard let name = declaration.typeName else {
            return
        }

        context.diagnose(
            Diagnostic(
                node: declaration,
                message: SwiftSyntaxMacroExpansion.MacroExpansionErrorMessage("A test class \(name) must inherit from XCTestCase.")
            )
        )
    }

    static func validateFileName(
        of declaration: DeclGroupSyntax,
        context: some MacroExpansionContext
    ) {
        guard
            let location = context.location(of: declaration),
            let stringLiteral = location.file.as(StringLiteralExprSyntax.self)?.segments.first,
            let urlString = stringLiteral.as(StringSegmentSyntax.self)?.content.text,
            let file = URLComponents(string: urlString)?.url?.lastPathComponent,
            (declaration.typeName ?? "") + ".swift" != file
        else {
            return
        }

        context.diagnose(
            Diagnostic(
                node: declaration,
                message: SwiftSyntaxMacroExpansion.MacroExpansionErrorMessage("Incorrect file name \"\(file)\", for the declaration of \"\(declaration.typeName ?? "")\"")
            )
        )
    }

    static func validateFunctionName(
        of declaration: FunctionDeclSyntax,
        in context: some MacroExpansionContext
    ) {
        let name = declaration.name.text

        if name.hasPrefix("test") {
            if let body = declaration.body {
                let (diagnostics, calls) = TestBodyAnalyser(viewMode: .fixedUp).analise(body)

                context.diagnose(diagnostics)

                if calls.isEmpty {
                    let diagnostic = Diagnostic(
                        node: declaration,
                        message: SwiftSyntaxMacroExpansion.MacroExpansionErrorMessage("Test case doesn't test any interface of the SUT.")
                    )
                    context.diagnose(diagnostic)
                } else {
                    let called = calls.filter { name.hasPrefix("test_\($0)_") }
                    if called.isEmpty {
                        let diagnostic = Diagnostic(
                            node: declaration,
                            message: SwiftSyntaxMacroExpansion.MacroExpansionErrorMessage("Test method should be declared with the following pattern:\n `func test_<interfaceUnderTest>_<testDescription>()`. Please rename it.")
                        )
                        context.diagnose(diagnostic)
                    }
                }
            }
            return
        }
    }

    static func validateSutDeclaration(
        of declaration: ClassDeclSyntax,
        in context: some MacroExpansionContext
    ) {
        if let sutType = declaration.variableDecls.identifiableNames["sut"] {
            if
                let sutTypeFromClassName = declaration.typeName?.deletingSuffix("Tests"),
                sutType != "\(sutTypeFromClassName)!" // Assuming implicitly unwrapped
            {
                context.diagnose(
                    Diagnostic(
                        node: declaration,
                        message: SwiftSyntaxMacroExpansion.MacroExpansionErrorMessage("Class name \(sutTypeFromClassName)Tests doesn't match the type of the SUT.")
                    )
                )
            }
        } else {
            context.diagnose(
                Diagnostic(
                    node: declaration,
                    message: SwiftSyntaxMacroExpansion.MacroExpansionErrorMessage("Test class \(declaration.typeName ?? "") doesn't have SUT declaration.")
                )
            )
        }
    }

    static func validateMembersOrder(
        of declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) {
        let diagnostics = ClassMembersOrderAnalyser(viewMode: .fixedUp).analise(declaration)
        context.diagnose(diagnostics)
    }
}

extension [VariableDeclSyntax] {
    fileprivate var identifiableNames: [String: String?] {
        /// ### Possible types:
        ///
        /// - ``ArrayTypeSyntax``
        /// - ``AttributedTypeSyntax``
        /// - ``ClassRestrictionTypeSyntax``
        /// - ``CompositionTypeSyntax``
        /// - ``DictionaryTypeSyntax``
        /// - ``FunctionTypeSyntax``
        /// - ``IdentifierTypeSyntax``
        /// - ``ImplicitlyUnwrappedOptionalTypeSyntax``
        /// - ``MemberTypeSyntax``
        /// - ``MetatypeTypeSyntax``
        /// - ``MissingTypeSyntax``
        /// - ``NamedOpaqueReturnTypeSyntax``
        /// - ``OptionalTypeSyntax``
        /// - ``PackElementTypeSyntax``
        /// - ``PackExpansionTypeSyntax``
        /// - ``SomeOrAnyTypeSyntax``
        /// - ``SuppressedTypeSyntax``
        /// - ``TupleTypeSyntax``

        let bindings = self.flatMap(\.bindings)

        var _names: [String: String] = [:]

        for binding in bindings {
            if let pattern = binding.pattern.as(IdentifierPatternSyntax.self) {
                _names[pattern.identifier.text] = binding.typeAnnotation?.type.description
            }
        }
        return _names
    }
}
