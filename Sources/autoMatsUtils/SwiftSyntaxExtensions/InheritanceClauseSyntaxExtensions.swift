//
//  InheritanceClauseSyntaxExtensions.swift
//
//
//  Created by Mateusz Kosikowski on 19/05/2024.
//

public import SwiftSyntax

extension InheritanceClauseSyntax {
    public var inheritanceTypeNames: [String] {
        inheritedTypes.compactMap { $0.type.as(IdentifierTypeSyntax.self)?.name.text }
    }
}
