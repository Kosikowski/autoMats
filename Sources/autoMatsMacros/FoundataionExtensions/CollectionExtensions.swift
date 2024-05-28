//
//  CollectionExtensions.swift
//
//
//  Created by Mateusz Kosikowski on 20/05/2024.
//

extension Collection {
    public subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
