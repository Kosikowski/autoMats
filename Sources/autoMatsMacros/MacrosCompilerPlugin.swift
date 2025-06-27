//
//  MacrosCompilerPlugin.swift
//
//
//  Created by Mateusz Kosikowski on 23/05/2024.
//

internal import SwiftCompilerPlugin
internal import SwiftSyntaxMacros

#if canImport(XCTest)
    @main
    struct syncMatPlugin: CompilerPlugin {
        let providingMacros: [Macro.Type] = [
            CleanTest.self,
            ExpectMultilineEqualMacro.self,
        ]
    }
#else
    @main
    struct syncMatPlugin: CompilerPlugin {
        let providingMacros: [Macro.Type] = [
        ]
    }

#endif
