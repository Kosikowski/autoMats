//
//  SkipAllTests.swift
//
//
//  Created by Mateusz Kosikowski on 23/05/2024.
//

import SwiftParser
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

@_spi(ExperimentalLanguageFeature) import SwiftSyntaxMacros
#if canImport(autoMatsMacros)
    @testable @_spi(ExperimentalLanguageFeature) import autoMatsMacros
#endif

class SkipAllTests: XCTestCase {
    func test_testThrowingFunction() throws {
        #if canImport(autoMatsMacros)

            assertMacroExpansion(
                """
                @SkipAll
                class My {
                    func test_myFunc() throws {
                    }
                }
                """,
                expandedSource:
                """
                class My {
                    @Skip
                    func test_myFunc() throws {
                    }
                }
                """,
                macros: ["SkipAll": SkipAll.self]
            )
        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func test_functionNotATest() throws {
        #if canImport(autoMatsMacros)

            assertMacroExpansion(
                """
                @SkipAll
                class My {
                    func helper() -> Int {
                        return 1
                    }
                }
                """,
                expandedSource:
                """
                class My {
                    func helper() -> Int {
                        return 1
                    }
                }
                """,
                macros: ["SkipAll": SkipAll.self]
            )
        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func test_testAsyncThrowingFunction() throws {
        #if canImport(autoMatsMacros)

            assertMacroExpansion(
                """
                @SkipAll
                class My {
                    func test() async throws {
                        return 1
                    }
                }
                """,
                expandedSource:
                """
                class My {
                    @Skip
                    func test() async throws {
                        return 1
                    }
                }
                """,
                macros: ["SkipAll": SkipAll.self]
            )
        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func test_noFunction() throws {
        #if canImport(autoMatsMacros)

            assertMacroExpansion(
                """
                @SkipAll
                class My {
                }
                """,
                expandedSource:
                """
                class My {
                }
                """,
                macros: ["SkipAll": SkipAll.self]
            )
        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func test_nonThrowingTestFunction() throws {
        #if canImport(autoMatsMacros)
            assertMacroExpansion(
                """
                @SkipAll
                class My {
                func test_ing() {
                }
                }
                """,
                expandedSource:
                """
                class My {
                func test_ing() {
                }
                }
                """,
                diagnostics: [
                    .init(
                        message: "@Skip can only be used with function that 'throws'.",
                        line: 3,
                        column: 1,
                        fixIts: [
                            .init(message: "add 'throws'"),
                        ]
                    ),
                ],
                macros: ["SkipAll": SkipAll.self]
            )
        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func test_nonThrowingTestAsyncFunction() throws {
        #if canImport(autoMatsMacros)
            assertMacroExpansion(
                """
                @SkipAll
                class My {
                func test_two() async {
                }
                }
                """,
                expandedSource:
                """
                class My {
                func test_two() async {
                }
                }
                """,
                diagnostics: [
                    .init(
                        message: "@Skip can only be used with function that 'throws'.",
                        line: 3,
                        column: 1,
                        fixIts: [
                            .init(message: "add 'throws'"),
                        ]
                    ),
                ],
                macros: ["SkipAll": SkipAll.self]
            )
        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func test_onExtension() throws {
        #if canImport(autoMatsMacros)
            assertMacroExpansion(
                """
                @SkipAll
                extension My {
                func test_two() async throws {
                }
                }
                """,
                expandedSource:
                """
                extension My {
                @Skip
                func test_two() async throws {
                }
                }
                """,
                macros: ["SkipAll": SkipAll.self]
            )
        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func test_onEnum() throws {
        #if canImport(autoMatsMacros)
            assertMacroExpansion(
                """
                @SkipAll
                enum My {
                func test_two() async throws {
                }
                }
                """,
                expandedSource:
                """
                enum My {
                func test_two() async throws {
                }
                }
                """,
                diagnostics: [
                    .init(
                        message: "@SkipAll works on classes and extensions only.",
                        line: 1,
                        column: 1
                    ),
                ],
                macros: ["SkipAll": SkipAll.self]
            )
        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
