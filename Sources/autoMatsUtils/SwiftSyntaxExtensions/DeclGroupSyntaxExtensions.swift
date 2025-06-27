//
//  DeclGroupSyntaxExtensions.swift
//
//
//  Created by Mateusz Kosikowski on 19/05/2024.
//

public import SwiftSyntax

extension DeclGroupSyntax {
    public var isClassDecl: Bool {
        kind == .classDecl
    }

    public var isExtensionDecl: Bool {
        kind == .extensionDecl
    }

    public var inheritanceTypeNames: [String] {
        inheritanceClause?.inheritanceTypeNames ?? []
    }

    public var isProtocolDecl: Bool {
        kind == .protocolDecl
    }

    public var typeName: String? {
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
