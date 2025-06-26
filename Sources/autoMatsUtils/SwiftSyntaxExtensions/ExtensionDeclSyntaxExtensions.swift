//
//  ExtensionDeclSyntaxExtensions.swift
//
//
//  Created by Mateusz Kosikowski on 19/05/2024.
//

public import SwiftSyntax

extension ExtensionDeclSyntax {
    public var typeName: String? {
        extendedType.as(IdentifierTypeSyntax.self)?.name.text
    }

    public var members: [MemberBlockItemSyntax] {
        memberBlock.members.map { $0 }
    }

    public var variableDecls: [VariableDeclSyntax] {
        members.compactMap { $0.decl.as(VariableDeclSyntax.self) }
    }

    public var functions: [FunctionDeclSyntax] {
        members.compactMap { $0.decl.as(FunctionDeclSyntax.self) }
    }
}
