//
//  MultilineEqualMacroTests.swift
//  autoMats
//
//  Created by Mateusz Kosikowski on 26/06/2025.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import Testing
@testable import autoMats
@testable import autoMatsMacros

struct MultilineEqualMacroTests {
    @Test func testMacroExpansion() {
        assertMacroExpansion(
            """
            #expectMultilineEqual("Hello\\nWorld", "Hello\\nWorld", trimWhitespace: true)
            """,
            expandedSource: """
            MultilineEqualUtils.expectMultilineEqual("Hello\\nWorld", "Hello\\nWorld", trimWhitespace: true, sourceLocation: #_sourceLocation)
            """,
            macros: ["expectMultilineEqual": ExpectMultilineEqualMacro.self]
        )
    }

    @Test func testInvalidArgumentCount() {
        assertMacroExpansion(
            """
            #expectMultilineEqual("Hello")
            """,
            expandedSource: "",
            diagnostics: [
                DiagnosticSpec(message: "invalidArgumentCount", line: 1, column: 1),
            ],
            macros: ["expectMultilineEqual": ExpectMultilineEqualMacro.self]
        )
    }

    @Test func testMethodBehavior() {
        // Test the underlying method directly
        let actual = """
        Hello
        World
        """
        let expected = """
        Hello
        World
        """
        expectMultilineEqual(actual, expected) // Should pass
    }
}
