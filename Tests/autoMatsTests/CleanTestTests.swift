//
//  CleanTestTests.swift
//
//
//  Created by Mateusz Kosikowski on 23/05/2024.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
@testable import autoMatsMacros

class CleanTestTests: XCTestCase {
    func test_emptyClassDeclaration() throws {
        #if canImport(autoMatsMacros)
            assertMacroExpansion(
                """
                @CleanTest
                class My2Tests: XCTestCase {
                }
                """,
                expandedSource:
                """
                class My2Tests: XCTestCase {
                }
                """,
                macros: ["CleanTest": CleanTest.self],
                testFileName: "My2Tests.swift"
            )
        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func test_cleanTest() throws {
        #if canImport(autoMatsMacros)
            assertMacroExpansion(
                """
                @CleanTest
                class My2Tests: XCTestCase {
                    var sut: My2!

                    func test_go_description() throws {
                        try sut.go()
                    }
                }
                """,
                expandedSource:
                """
                class My2Tests: XCTestCase {
                    var sut: My2!

                    func test_go_description() throws {
                        try sut.go()
                    }
                }
                """,
                macros: ["CleanTest": CleanTest.self],
                testFileName: "My2Tests.swift"
            )
        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func test_macroOnExtension() throws {
        #if canImport(autoMatsMacros)
            assertMacroExpansion(
                """
                @CleanTest
                extension MyTests {
                    func test_go_description() throws {
                        try sut.go()
                    }
                }
                """,
                expandedSource:
                """
                extension MyTests {
                    func test_go_description() throws {
                        try sut.go()
                    }
                }
                """,
                macros: ["CleanTest": CleanTest.self],
                testFileName: "MyTests.swift"
            )
        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func test_macroOnStruct() throws {
        #if canImport(autoMatsMacros)
            assertMacroExpansion(
                """
                @CleanTest
                struct MyTests {
                    func test() {}
                }
                """,
                expandedSource:
                """
                struct MyTests {
                    func test() {}
                }
                """,
                diagnostics: [
                    .init(
                        message: "@CleanTest can only be used in class declarations subclassing XCTestCase, or extensions.",
                        line: 1,
                        column: 1
                    ),
                ],
                macros: ["CleanTest": CleanTest.self],
                testFileName: "MyTests.swift"
            )
        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func test_macroOnActor() throws {
        #if canImport(autoMatsMacros)
            assertMacroExpansion(
                """
                @CleanTest
                actor MyTests {
                    func t() {}
                }
                """,
                expandedSource:
                """
                actor MyTests {
                    func t() {}
                }
                """,
                diagnostics: [
                    .init(
                        message: "@CleanTest can only be used in class declarations subclassing XCTestCase, or extensions.",
                        line: 1,
                        column: 1
                    ),
                ],
                macros: ["CleanTest": CleanTest.self],
                testFileName: "MyTests.swift"
            )
        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func test_macroInheritance() throws {
        #if canImport(autoMatsMacros)
            assertMacroExpansion(
                """
                @CleanTest
                class MyTests {
                    var sut: My!
                    func test_fun_2() {
                        sut.fun()
                    }
                }
                """,
                expandedSource:
                """
                class MyTests {
                    var sut: My!
                    func test_fun_2() {
                        sut.fun()
                    }
                }
                """,
                diagnostics: [
                    .init(
                        message: "A test class MyTests must inherit from XCTestCase.",
                        line: 1,
                        column: 1
                    ),
                ],
                macros: ["CleanTest": CleanTest.self],
                testFileName: "MyTests.swift"
            )
        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func test_noSutVariableInTestClass() throws {
        #if canImport(autoMatsMacros)
            assertMacroExpansion(
                """
                @CleanTest
                class MyTests: XCTestCase {
                    var sub: My!

                    func test_go_description() throws {
                        try sut.go()
                    }
                }
                """,
                expandedSource:
                """
                class MyTests: XCTestCase {
                    var sub: My!

                    func test_go_description() throws {
                        try sut.go()
                    }
                }
                """,
                diagnostics: [
                    .init(
                        message: "Test class MyTests doesn't have SUT declaration.",
                        line: 1,
                        column: 1
                    ),
                ],
                macros: ["CleanTest": CleanTest.self],
                testFileName: "MyTests.swift"
            )
        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func test_incorrectFileVsClassName() throws {
        #if canImport(autoMatsMacros)
            assertMacroExpansion(
                """
                @CleanTest
                class MyTests: XCTestCase {
                    var sut: My!

                    func test_go_description() throws {
                        try sut.go()
                    }
                }
                """,
                expandedSource:
                """
                class MyTests: XCTestCase {
                    var sut: My!

                    func test_go_description() throws {
                        try sut.go()
                    }
                }
                """,
                diagnostics: [
                    .init(
                        message: "Incorrect file name \"NotMyTests.swift\", for the declaration of \"MyTests\"",
                        line: 1,
                        column: 1
                    ),
                ],
                macros: ["CleanTest": CleanTest.self],
                testFileName: "NotMyTests.swift"
            )
        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func test_incorrectClassName() throws {
        #if canImport(autoMatsMacros)
            assertMacroExpansion(
                """
                @CleanTest
                class MyTesta: XCTestCase {
                    var sut: My!

                    func test_go_description() throws {
                        try sut.go()
                    }
                }
                """,
                expandedSource:
                """
                class MyTesta: XCTestCase {
                    var sut: My!

                    func test_go_description() throws {
                        try sut.go()
                    }
                }
                """,
                diagnostics: [
                    .init(
                        message: "MyTesta name must end with \"Tests\".",
                        line: 1,
                        column: 1
                    ),
                    .init(
                        message: "Class name MyTestaTests doesn't match the type of the SUT.",
                        line: 1,
                        column: 1
                    ),
                ],
                macros: ["CleanTest": CleanTest.self],
                testFileName: "MyTesta.swift"
            )
        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func test_noSutCallInATest() throws {
        #if canImport(autoMatsMacros)
            assertMacroExpansion(
                """
                @CleanTest
                class MyTests: XCTestCase {
                    var sut: My!

                    func test_go_description() throws {
                    }
                }
                """,
                expandedSource:
                """
                class MyTests: XCTestCase {
                    var sut: My!

                    func test_go_description() throws {
                    }
                }
                """,
                diagnostics: [
                    .init(
                        message: "Test case doesn't test any interface of the SUT.",
                        line: 5,
                        column: 5
                    ),

                ],
                macros: ["CleanTest": CleanTest.self],
                testFileName: "MyTests.swift"
            )
        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func test_incorrectMethodsNameVsSutCall() throws {
        #if canImport(autoMatsMacros)
            assertMacroExpansion(
                """
                @CleanTest
                class MyTests: XCTestCase {
                    var sut: My!

                    func test_gogoDescription() throws {
                        sut.gogo()
                    }
                }
                """,
                expandedSource:
                """
                class MyTests: XCTestCase {
                    var sut: My!

                    func test_gogoDescription() throws {
                        sut.gogo()
                    }
                }
                """,
                diagnostics: [
                    .init(
                        message: "Test method should be declared with the following pattern:\n `func test_<interfaceUnderTest>_<testDescription>()`. Please rename it.",
                        line: 5,
                        column: 5
                    ),

                ],
                macros: ["CleanTest": CleanTest.self],
                testFileName: "MyTests.swift"
            )
        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func test_incorrectMethodsNameVsSutCallV2() throws {
        #if canImport(autoMatsMacros)
            assertMacroExpansion(
                """
                @CleanTest
                class MyTests: XCTestCase {
                    var sut: My!

                    func test_go_description() throws {
                        sut.gogo()
                    }
                }
                """,
                expandedSource:
                """
                class MyTests: XCTestCase {
                    var sut: My!

                    func test_go_description() throws {
                        sut.gogo()
                    }
                }
                """,
                diagnostics: [
                    .init(
                        message: "Test method should be declared with the following pattern:\n `func test_<interfaceUnderTest>_<testDescription>()`. Please rename it.",
                        line: 5,
                        column: 5
                    ),

                ],
                macros: ["CleanTest": CleanTest.self],
                testFileName: "MyTests.swift"
            )
        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func test_optionalTryCallInATest() throws {
        #if canImport(autoMatsMacros)
            assertMacroExpansion(
                """
                @CleanTest
                class MyTests: XCTestCase {
                    var sut: My!

                    func test_gogo_w() throws {
                        try? sut.gogo()
                    }
                }
                """,
                expandedSource:
                """
                class MyTests: XCTestCase {
                    var sut: My!

                    func test_gogo_w() throws {
                        try? sut.gogo()
                    }
                }
                """,
                diagnostics: [
                    .init(
                        message: "Optional-try expressions should not be used in tests.",
                        line: 6,
                        column: 9,
                        fixIts: [
                            .init(message: "remove '?'"),
                        ]
                    ),
                ],
                macros: ["CleanTest": CleanTest.self],
                testFileName: "MyTests.swift"
            )
        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func test_membersOrder_variablesShouldBeAtTheBegginig() throws {
        #if canImport(autoMatsMacros)
            assertMacroExpansion(
                """
                @CleanTest
                class MyTests: XCTestCase {
                    func test_gogo_w() throws {
                        try sut.gogo()
                    }
                    var sut: My!
                }
                """,
                expandedSource:
                """
                class MyTests: XCTestCase {
                    func test_gogo_w() throws {
                        try sut.gogo()
                    }
                    var sut: My!
                }
                """,
                diagnostics: [
                    .init(
                        message: "All variables should be declared at the beginning of the class.",
                        line: 6,
                        column: 5
                    ),
                ],
                macros: ["CleanTest": CleanTest.self],
                testFileName: "MyTests.swift"
            )
        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func test_membersOrder_testMethodInItsSection() throws {
        #if canImport(autoMatsMacros)
            assertMacroExpansion(
                """
                @CleanTest
                class MyTests: XCTestCase {
                    var sut: My!
                    // MARK: - goga
                    func test_gogo_w() throws {
                        try sut.gogo()
                    }
                }
                """,
                expandedSource:
                """
                class MyTests: XCTestCase {
                    var sut: My!
                    // MARK: - goga
                    func test_gogo_w() throws {
                        try sut.gogo()
                    }
                }
                """,
                diagnostics: [
                    .init(
                        message: "The test_gogo_w method must belong to a \"// MARK: - gogo <optinoalComment>\" section.",
                        line: 5,
                        column: 5
                    ),
                ],
                macros: ["CleanTest": CleanTest.self],
                testFileName: "MyTests.swift"
            )
        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func test_membersOrder_helperMethodInBetweenTests() throws {
        #if canImport(autoMatsMacros)
            assertMacroExpansion(
                """
                @CleanTest
                class MyTests: XCTestCase {
                    var sut: My!
                    // MARK: - gogo
                    func test_gogo_w() throws {
                        try sut.gogo()
                    }

                    func w() throws {
                    }
                }
                """,
                expandedSource:
                """
                class MyTests: XCTestCase {
                    var sut: My!
                    // MARK: - gogo
                    func test_gogo_w() throws {
                        try sut.gogo()
                    }

                    func w() throws {
                    }
                }
                """,
                diagnostics: [
                    .init(
                        message: "The w helper method must be in a \"// MARK: - helper methods\" section, or moved to a designated extension.",
                        line: 9,
                        column: 5
                    ),
                ],
                macros: ["CleanTest": CleanTest.self],
                testFileName: "MyTests.swift"
            )
        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func test_markCommentFormat() throws {
        #if canImport(autoMatsMacros)
            assertMacroExpansion(
                """
                @CleanTest
                class MyTests: XCTestCase {
                    var sut: My!
                    // MARK:- gogo
                    func test_gogo_w() throws {
                        try sut.gogo()
                    }
                    //MARK: - helper methods
                    func w() throws {
                    }
                }
                """,
                expandedSource:
                """
                class MyTests: XCTestCase {
                    var sut: My!
                    // MARK:- gogo
                    func test_gogo_w() throws {
                        try sut.gogo()
                    }
                    //MARK: - helper methods
                    func w() throws {
                    }
                }
                """,
                diagnostics: [
                    .init(
                        message: "The MARK comment should be formatted as : \"// MARK: - `interfaceUderTest` `optional description`\"",
                        line: 5,
                        column: 5
                    ),
                    .init(
                        message: "The MARK comment should be formatted as : \"// MARK: - `interfaceUderTest` `optional description`\"",
                        line: 9,
                        column: 5
                    ),
                ],
                macros: ["CleanTest": CleanTest.self],
                testFileName: "MyTests.swift"
            )
        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
