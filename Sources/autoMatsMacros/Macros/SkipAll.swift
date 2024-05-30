//
//  SkipAll.swift
//
//
//  Created by Mateusz Kosikowski on 22/05/2024.
//

internal import SwiftCompilerPlugin
internal import SwiftDiagnostics
public import SwiftSyntax
public import SwiftSyntaxMacros

@_spi(ExperimentalLanguageFeature) public import SwiftSyntaxMacros

/// A public structure representing a member attribute macro called `SkipAll`.
/// This macro is designed to automatically skip all test methods within a class
/// or extension by applying the `@Skip` attribute to those methods.
///
/// Usage: `@SkipAll`
///
@_spi(ExperimentalLanguageFeature)
public struct SkipAll: MemberAttributeMacro {
    /// Generates the expansion code for the `SkipAll` macro.
    ///
    /// - Parameters:
    ///   - node: The attribute syntax node representing the macro attribute.
    ///   - declaration: The declaration group syntax node to which the macro is attached (class or extension).
    ///   - member: The member declaration syntax node for which attributes are being provided (test method).
    ///   - context: The macro expansion context.
    /// - Throws: A `SwiftSyntaxMacros.MacroExpansionErrorMessage` if `SkipAll` is applied
    ///             to a declaration other than a class or extension, or if an error occurs
    ///             during the evaluation of the `Skip` macro.
    /// - Returns: An array of attribute syntax nodes, containing the `@Skip` attribute if applicable.
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        // Check if the declaration is a class or extension
        guard declaration.isClassDecl || declaration.isExtensionDecl else {
            throw SwiftSyntaxMacros.MacroExpansionErrorMessage("@\(Self.self) works on classes and extensions only.")
        }

        // Check if the member is a function declaration (test method)
        guard
            let function = member.as(FunctionDeclSyntax.self),
            function.name.text.hasPrefix("test")
        else {
            return []
        }

        // Evaluate the Skip macro to potentially skip with an error.
        let _ = try Skip.expansion(of: node, providingPreambleFor: function, in: context)

        // If no error is thrown, add the @Skip attribute
        return ["@\(Skip.self)"]
    }
}
