//
//  StructDeclSyntaxExtensions.swift
//
//
//  Created by Mateusz Kosikowski on 19/05/2024.
//

internal import SwiftSyntax

extension StructDeclSyntax {
    var typeName: String? {
        name.text
    }
}
