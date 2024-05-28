//
//  SkipAll.swift
//
//
//  Created by Mateusz Kosikowski on 22/05/2024.
//

internal import Foundation
internal import SwiftCompilerPlugin
internal import SwiftDiagnostics
internal import SwiftSyntax
internal import SwiftSyntaxMacros

@_spi(ExperimentalLanguageFeature) import SwiftSyntaxMacros

@_spi(ExperimentalLanguageFeature)
public struct SkipAll: MemberAttributeMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        guard declaration.isClassDecl || declaration.isExtensionDecl else {
            throw SwiftSyntaxMacros.MacroExpansionErrorMessage("@\(Self.self) works on classes and extensions only.")
        }

        guard
            let function = member.as(FunctionDeclSyntax.self),
            function.name.text.hasPrefix("test")
        else {
            return []
        }

        // We are evaluating the `SkipAll` macro to throw a potential error.
        let _ = try Skip.expansion(of: node, providingPreambleFor: function, in: context)

        // If no error is thrown the `@Skip` attribute can be added.
        return ["@\(Skip.self)"]
    }
}
