//
//  MultilineEqualTests.swift
//
//
//  Created by Mateusz Kosikowski on 23/06/2025.
//

import autoMats
import Testing
@testable import autoMatsMacros

struct MultilineEqualTests {
//    @Test func testMultilineEqual() {
//        let actual = """
//        Hello
//        World
//        """
//        let expected = """
//        Hello
//        World
//        """
//        #expectMultilineEqual(actual, expected) // Passes, calls expectMultilineEqual
//
//        let actualWithMismatch = """
//        Hello
//        World!
//        """
//        #expectMultilineEqual(actualWithMismatch, expected) // Fails with detailed message
//    }
//
//    @Test func testTrimWhitespace() {
//        let actual = """
//          Hello
//        World
//        """
//        let expected = """
//        Hello
//        World
//        """
//        #expectMultilineEqual(actual, expected, trimWhitespace: true) // Passes
//    }

    @Test func testDirectMethodCall() {
        // Verify the method can be called directly
        let actual = """
        Hello
        World
        """
        let expected = """
        Hello
        World
        """
        expectMultilineEqual(actual, expected) // Passes
    }
}
