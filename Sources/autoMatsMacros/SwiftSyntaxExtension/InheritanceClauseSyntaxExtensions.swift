//
//  InheritanceClauseSyntaxExtensions.swift
//
//
//  Created by Mateusz Kosikowski on 19/05/2024.
//

import SwiftSyntax

extension InheritanceClauseSyntax {
    var inheritanceTypeNames: [String] {
        inheritedTypes.compactMap { $0.type.as(IdentifierTypeSyntax.self)?.name.text }
    }
}
