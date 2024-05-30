//
//  MacrosCompilerPlugin.swift
//
//
//  Created by Mateusz Kosikowski on 23/05/2024.
//

@_spi(ExperimentalLanguageFeature) internal import SwiftSyntaxMacros
internal import SwiftCompilerPlugin
internal import SwiftSyntaxMacros

@main
struct syncMatPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        CleanTest.self,
        Skip.self,
        SkipAll.self,
    ]
}
