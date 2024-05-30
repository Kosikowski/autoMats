//
//  CleanTest.swift
//
//
//  Created by Mateusz Kosikowski on 27/05/2024.
//

internal import Foundation
internal import SwiftDiagnostics
public import SwiftSyntax
internal import SwiftSyntaxMacroExpansion
public import SwiftSyntaxMacros

/// ### CleanTest Macro
/// ## Description:
///
/// The CleanTest macro is a diagnostic tool designed to ensure that your ``XCTestCase`` classes
/// adhere to best practices in formatting and structure. It automates the verification
/// of key aspects of your test cases, providing guidance and enforcement of a clean
/// and consistent codebase for your unit tests.
///
/// ## Features:
///
/// Method Naming Conventions: Ensures all test methods within the ``XCTestCase`` class
/// follow a consistent naming convention (e.g., prefixed with test and descriptively named).
///
/// TODO: Setup and Teardown Methods: Verifies the presence and proper usage of setUp()
/// and tearDown() methods for initializing and cleaning up test environments.
///
/// TODO: Test Assertions: Checks that test methods contain appropriate assertions
/// (``XCTAssert``, ``XCTAssertEqual``, etc.) to validate expected outcomes.
///
/// TODO: Test Coverage: Ensures that each test method is meaningful and covers
/// a distinct aspect of the functionality being tested.
///
/// Clear Test Structure: Enforces a clear and logical structure within the ``XCTestCase`` class,
/// including grouping related test methods and maintaining a clean class organization.
///
/// ## Usage:
/// To use the ``CleanTest`` macro, simply apply it to your ``XCTestCase`` classes.
/// The macro will automatically analyze the class and raise diagnostic error
/// to ensure compliance with the outlined best practices.
///
public struct CleanTest: MemberAttributeMacro {
    
    /// Validate and process the declaration block for the `@CleanTest` macro.
    /// - Parameters:
    ///   - declaration: The declaration group syntax node representing the test class or extension.
    ///   - member: The member syntax node for which the `@CleanTest` macro is applied.
    ///   - node: The attribute syntax node for the `@CleanTest` macro.
    ///   - context: The macro expansion context.
    /// - Returns: An array of attribute syntax nodes.
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {

        // Ensure that the member being processed matches the first member in the declaration block.
        // This check is necessary because this macro is invoked for every member of the class.
        // We perform validation for the entire class as soon as this method is invoked for the first
        // member in the declaration.
        guard
            let decl = declaration.memberBlock.members.first?.decl,
            decl.description == member.description
        else {
            return []
        }

        // Check if the declaration is an extension or a class declaration
        if declaration.isExtensionDecl {
            // If it's an extension, validate the extension declaration
            validateExtensionDeclaration(declaration.as(ExtensionDeclSyntax.self)!, in: context)
        } else if declaration.isClassDecl {
            // If it's a class declaration, validate the class declaration
            validateClassDeclaration(declaration.as(ClassDeclSyntax.self)!, in: context)
        } else {
            // If it's neither an extension nor a class declaration, raise a diagnostic error
            context.diagnose(Diagnostic(
                node: node,
                message: SwiftSyntaxMacroExpansion.MacroExpansionErrorMessage("@CleanTest can only be used in class declarations subclassing XCTestCase, or extensions.")
            ))
        }
        
        // Return empty array, as this macro is diagnostic macro only and it does not generate any code.
        return []
    }

    // MARK: - validation

    /// Validates an extension declaration.
    ///
    /// - Parameters:
    ///   - declaration: The `ExtensionDeclSyntax` representing the extension declaration.
    ///   - context: The `MacroExpansionContext` providing the context for validation.
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

    /// Validates a class declaration.
    ///
    /// - Parameters:
    ///   - declaration: The `ClassDeclSyntax` representing the class declaration.
    ///   - context: The `MacroExpansionContext` providing the context for validation.
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

    /// This method checks if the type name of a declaration conforms to naming conventions
    /// by ensuring it ends with "Tests". If the type name does not end with "Tests",
    /// a diagnostic error is raised using the provided `MacroExpansionContext`.
    ///
    /// - Parameters:
    ///   - declaration: The declaration group syntax node representing the declaration to be validated.
    ///   - context: The `MacroExpansionContext` used to report diagnostic errors.
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

    /// This method checks if the inheritance clause of a declaration includes the expected type,
    /// specifically `XCTestCase`. If the inheritance clause does not contain `XCTestCase`,
    /// a diagnostic error is reported using the provided `MacroExpansionContext`.
    /// This method is used to enforce that test case classes inherit from `XCTestCase`.
    ///
    /// - Parameters:
    ///   - declaration: The declaration group syntax node representing the declaration to be validated.
    ///   - context: The `MacroExpansionContext` used to report diagnostic errors.
    static func validateInheritanceClause(
        of declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) {
        guard
            let inheritanceClause = declaration.inheritanceClause,
            inheritanceClause.inheritanceTypeNames.contains("XCTestCase")
        else {
            context.diagnose(
                Diagnostic(
                    node: declaration,
                    message: SwiftSyntaxMacroExpansion.MacroExpansionErrorMessage("A test class \(declaration.typeName!) must inherit from XCTestCase.")
                )
            )
            return
        }
    }

    /// This method extracts the file name from the location of the declaration within the source
    /// code and compares it with the expected file name derived from the declaration's type name.
    /// If the file name does not match the expected convention, a diagnostic error is reported
    /// using the provided `MacroExpansionContext`.
    ///
    /// This method is used to enforce consistency between file names and declaration names.
    ///
    /// - Parameters:
    ///   - declaration: The declaration group syntax node representing the declaration to be validated.
    ///   - context: The `MacroExpansionContext` used to report diagnostic errors.
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

    /// Validates the function name of test methods by checking if they call any interface
    /// of the System Under Test.
    ///
    /// - Parameters:
    ///   - declaration: The `FunctionDeclSyntax` representing the test method to validate.
    ///   - context: The `MacroExpansionContext` providing the context for diagnostics and analysis.
    static func validateFunctionName(
        of declaration: FunctionDeclSyntax,
        in context: some MacroExpansionContext
    ) {
        let name = declaration.name.text
        
        // Check if the function is a test method
        if name.hasPrefix("test") {
            if let body = declaration.body {
                let (diagnostics, calls) = TestBodyAnalyser(viewMode: .fixedUp).analise(body)

                context.diagnose(diagnostics)
                
                // Check if the test method calls any interface of the SUT (System Under Test)
                if calls.isEmpty {
                    // Report a diagnostic if the test case doesn't test any interface of the SUT
                    let diagnostic = Diagnostic(
                        node: declaration,
                        message: SwiftSyntaxMacroExpansion.MacroExpansionErrorMessage("Test case doesn't test any interface of the SUT.")
                    )
                    context.diagnose(diagnostic)
                } else {
                    // Check if the test method follows the naming convention
                    let called = calls.filter { name.hasPrefix("test_\($0)_") }
                    if called.isEmpty {
                        // Report a diagnostic
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

    /// Validates the name and structure of a test method declaration.
    ///
    /// This method examines the name of the function declaration to determine if it represents
    /// a test case. If the function is identified as a test case (prefixed with "test"),
    /// the method analyzes its body using ``TestBodyAnalyser`` to ensure that it tests
    /// at least one interface of the System Under Test (SUT). It reports diagnostic errors
    /// if the test case does not call any interface of the SUT or if the naming pattern
    /// of the test method does not follow the expected convention. Test methods are expected
    /// to follow the pattern: `func test_<interfaceUnderTest>_<testDescription>()`.
    ///
    /// - Parameters:
    ///   - declaration: The `FunctionDeclSyntax` node representing the test method declaration to be validated.
    ///   - context: The `MacroExpansionContext` used to report diagnostic errors.
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

    /// This method analyzes the order of variables and functions within the declaration
    /// group syntax node using `ClassMembersOrderAnalyser`.
    /// It checks if variables are declared before functions and verifies the proper organization
    /// of test methods and helper methods within the class. Diagnostic errors are reported
    /// using the provided `MacroExpansionContext` if any violations of the specified conventions
    /// are detected.
    ///
    /// - Parameters:
    ///   - declaration: The declaration group syntax node representing the members to be validated.
    ///   - context: The `MacroExpansionContext` used to report diagnostic errors.
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
