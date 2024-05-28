//
//  DeclGroupSyntaxExtensions.swift
//
//
//  Created by Mateusz Kosikowski on 19/05/2024.
//

import SwiftSyntax

extension DeclGroupSyntax {
    var isClassDecl: Bool {
        kind == .classDecl
    }

    var isExtensionDecl: Bool {
        kind == .extensionDecl
    }

    var inheritanceTypeNames: [String] {
        inheritanceClause?.inheritanceTypeNames ?? []
    }

    var isProtocolDecl: Bool {
        kind == .protocolDecl
    }

    var typeName: String? {
        if let name = self.as(ActorDeclSyntax.self)?.typeName {
            return name
        }

        if let name = self.as(ExtensionDeclSyntax.self)?.typeName {
            return name
        }

        if let name = self.as(ClassDeclSyntax.self)?.typeName {
            return name
        }

        if let name = self.as(StructDeclSyntax.self)?.typeName {
            return name
        }

        if let name = self.as(EnumDeclSyntax.self)?.typeName {
            return name
        }

        return nil
    }
}
