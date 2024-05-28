//
//  CleanTestTests.swift
//
//
//  Created by Mateusz Kosikowski on 23/05/2024.
//

@testable import autoMatsMacros
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

class CleanTestTests: XCTestCase {
    func test_cleanTest_throwingFunction() throws {
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
}
