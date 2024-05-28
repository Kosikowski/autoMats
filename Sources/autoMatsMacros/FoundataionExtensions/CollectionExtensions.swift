//
//  CollectionExtensions.swift
//
//
//  Created by Mateusz Kosikowski on 20/05/2024.
//

import Foundation

public extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
