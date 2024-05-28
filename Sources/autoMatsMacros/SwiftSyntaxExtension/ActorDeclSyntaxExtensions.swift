//
//  ActorDeclSyntaxExtensions.swift
//
//
//  Created by Mateusz Kosikowski on 19/05/2024.
//

import SwiftSyntax

extension ActorDeclSyntax {
    var typeName: String? {
        name.text
    }
}
