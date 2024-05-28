//
//  ForDebuggingOnly.swift
//
//
//  Created by Mateusz Kosikowski on 23/05/2024.
//

@testable import autoMatsMacros
import SwiftParser
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

class CleanTestTests2: XCTestCase {
    let text: String = """
    class MyTestClass {
        var sut: MySut!
    }
    """

    func test_testThrowingFunction() throws {
        let p = Parser.parse(source: text)
        let visitor = SyntaxVisitor(viewMode: .fixedUp)
        visitor.walk(p)
    }
}
