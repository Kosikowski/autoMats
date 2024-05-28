//
//  TuplePatternElementListSyntaxExtensions.swift
//
//
//  Created by Mateusz Kosikowski on 19/05/2024.
//

internal import SwiftSyntax

extension TuplePatternElementListSyntax {
    var elements: [TuplePatternElementSyntax] {
        map { $0 }
    }
}
