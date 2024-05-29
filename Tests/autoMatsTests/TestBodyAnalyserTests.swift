//
//  TestBodyAnalyserTests.swift
//
//
//  Created by Mateusz Kosikowski on 23/05/2024.
//

internal import SwiftParser
internal import SwiftSyntaxMacros
internal import SwiftSyntaxMacrosTestSupport
internal import XCTest
@testable import autoMatsMacros

class TestBodyAnalyserTests: XCTestCase {
    func test_analise_detectsOptionalTryExpressions() throws {
        let testSyntax = """
        func callable() -> {
            let call = {
                guard more else { return }
                if true {
                    john.doSomething()
                }
            }
            try? callingYou()
            return and.makeIt.done()
            do {
                if a > 0 {
                    try? _sut.anotherMike()
                }
            }
            catch {
                try! ive.finished()
            }
        }
        """
        let source = Parser.parse(source: testSyntax)
        let analyser = TestBodyAnalyser(viewMode: .fixedUp)

        let (diagnostics, calls) = analyser.analise(source)
        XCTAssertEqual(calls.count, 0)

        XCTAssertEqual(diagnostics.count, 2)
        XCTAssertEqual(diagnostics[0].message, "Optional-try expressions should not be used in tests.")
        XCTAssertEqual(diagnostics[1].message, "Optional-try expressions should not be used in tests.")
    }

    func test_analise_detectsAllSutCalls() throws {
        let testSyntax = """
        func callable() -> {
            let call = {
                guard more else { return }
                if true {
                    sut.doSomething()
                }
            }
            try callingYou()
            return _sut.mike.done()
            do {
                if a > 0 {
                    try sut.anotherMike()
                }
            }
            catch {
                try! sut.finished()
            }
        }
        """
        let source = Parser.parse(source: testSyntax)
        let analyser = TestBodyAnalyser(viewMode: .fixedUp)

        let (diagnostics, calls) = analyser.analise(source)
        XCTAssertEqual(calls, ["doSomething", "anotherMike", "finished"])
        XCTAssertEqual(diagnostics.count, 0)
    }
}
