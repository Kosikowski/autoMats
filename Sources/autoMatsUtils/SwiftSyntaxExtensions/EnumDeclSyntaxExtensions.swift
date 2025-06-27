//
//  EnumDeclSyntaxExtensions.swift
//
//
//  Created by Mateusz Kosikowski on 19/05/2024.
//

internal import SwiftSyntax

extension EnumDeclSyntax {
    var typeName: String? {
        name.text
    }
}
