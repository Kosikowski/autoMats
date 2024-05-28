//
//  MacrosCompilerPlugin.swift
//
//
//  Created by Mateusz Kosikowski on 23/05/2024.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros
@_spi(ExperimentalLanguageFeature) import SwiftSyntaxMacros

@main
struct syncMatPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        CleanTest.self,
        Skip.self,
        SkipAll.self,
    ]
}
