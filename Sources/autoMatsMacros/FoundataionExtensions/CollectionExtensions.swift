//
//  CollectionExtensions.swift
//
//
//  Created by Mateusz Kosikowski on 20/05/2024.
//

extension Collection {
    /// Returns an element if the index is within the valid range of the collection.
    ///
    /// - Parameters:
    /// - index: The index of the element to retrieve.
    /// - Returns: The element at the specified index if within range, otherwise nil.
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
