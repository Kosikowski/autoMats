//
//  ClassDeclSyntaxExtensions.swift
//
//
//  Created by Mateusz Kosikowski on 19/05/2024.
//

internal import SwiftSyntax

extension ClassDeclSyntax {
    var members: [MemberBlockItemSyntax] {
        memberBlock.members.map { $0 }
    }

    var variableDecls: [VariableDeclSyntax] {
        members.compactMap { $0.decl.as(VariableDeclSyntax.self) }
    }

    var functions: [FunctionDeclSyntax] {
        members.compactMap { $0.decl.as(FunctionDeclSyntax.self) }
    }

    var typeName: String? {
        name.text
    }
}
