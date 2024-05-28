//
//  SkipTests.swift
//
//
//  Created by Mateusz Kosikowski on 23/05/2024.
//

@testable import autoMatsMacros
import SwiftParser
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

@_spi(ExperimentalLanguageFeature) import SwiftSyntaxMacros
#if canImport(autoMatsMacros)
    @testable @_spi(ExperimentalLanguageFeature) import autoMatsMacros
#endif

class SkipTests: XCTestCase {
    func test_SkipOnThrowingFunction() throws {
        #if canImport(autoMatsMacros)
            assertMacroExpansion(
                """
                class My {
                @Skip
                func test_myFunc() throws {
                    print("here")
                }
                }
                """,
                expandedSource:
                """
                class My {
                func test_myFunc() throws {
                    throw XCTSkip("⚠️ This test is ignored due to the effect of the @Skip macro.")
                    print("here")
                }
                }
                """,

                macros: ["Skip": Skip.self]
            )
        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func test_SkipOnAsyncThrowingFunction() throws {
        #if canImport(autoMatsMacros)
            assertMacroExpansion(
                """
                class My {
                @Skip
                func test_myFunc() async throws {
                    print("here")
                }
                }
                """,
                expandedSource:
                """
                class My {
                func test_myFunc() async throws {
                    throw XCTSkip("⚠️ This test is ignored due to the effect of the @Skip macro.")
                    print("here")
                }
                }
                """,

                macros: ["Skip": Skip.self]
            )
        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func test_SkipOnAsyncThrowingFunction_withAdditionalAttribute() throws {
        #if canImport(autoMatsMacros)
            assertMacroExpansion(
                """
                class My {
                @Skip
                @SomeMacro
                func test_myFunc() async throws {
                    print("here")
                }
                }
                """,
                expandedSource:
                """
                class My {
                @SomeMacro
                func test_myFunc() async throws {
                    throw XCTSkip("⚠️ This test is ignored due to the effect of the @Skip macro.")
                    print("here")
                }
                }
                """,

                macros: ["Skip": Skip.self]
            )
        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func test_SkipOnAFunctionThatDoesntStartWith_test() throws {
        #if canImport(autoMatsMacros)
            assertMacroExpansion(
                """
                class My {
                @Aloha
                @SomeMacro
                func tet_myFunc() async throws {
                    print("here")
                }
                }
                """,
                expandedSource:
                """
                class My {
                @SomeMacro
                func tet_myFunc() async throws {
                    print("here")
                }
                }
                """,
                diagnostics: [
                    .init(
                        message: "@Skip affects functions whose name starts with 'test'.",
                        line: 2,
                        column: 1
                    ),
                ],
                macros: ["Aloha": Skip.self]
            )
        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func test_SkipOnAnAsyncFunction() throws {
        #if canImport(autoMatsMacros)
            assertMacroExpansion(
                """
                class My {
                @Aloha
                func test_myFunc() async {
                    print("here")
                }
                }
                """,
                expandedSource:
                """
                class My {
                func test_myFunc() async {
                    print("here")
                }
                }
                """,
                diagnostics: [
                    .init(
                        message: "@Skip can only be used with function that 'throws'.",
                        line: 2,
                        column: 1,
                        fixIts: [
                            .init(message: "add 'throws'"),
                        ]
                    ),
                ],
                macros: ["Aloha": Skip.self]
            )
        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
