//
//  MacrosCompilerPlugin.swift
//
//
//  Created by Mateusz Kosikowski on 23/05/2024.
//

internal import SwiftCompilerPlugin
internal import SwiftSyntaxMacros

@main
struct syncMatPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        CleanTest.self,
    ]
}
