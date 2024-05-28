//
//  ExtensionDeclSyntaxExtensions.swift
//
//
//  Created by Mateusz Kosikowski on 19/05/2024.
//

import SwiftSyntax

extension ExtensionDeclSyntax {
    var typeName: String? {
        extendedType.as(IdentifierTypeSyntax.self)?.name.text
    }

    var members: [MemberBlockItemSyntax] {
        memberBlock.members.map { $0 }
    }

    var variableDecls: [VariableDeclSyntax] {
        members.compactMap { $0.decl.as(VariableDeclSyntax.self) }
    }

    var functions: [FunctionDeclSyntax] {
        members.compactMap { $0.decl.as(FunctionDeclSyntax.self) }
    }
}
