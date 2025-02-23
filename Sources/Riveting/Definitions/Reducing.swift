//
//  Reducer.swift
//  Riveting
//
//  Created by Ethan Van Heerden on 2/22/25.
//

/// A Reducing type is a mapper of a Domain state to a View State used for View updates.
/// It is useful to put our Domain (model) representation into a more convenient type to create
/// Views from,
protocol Reducing: Sendable {
    associatedtype Domain: Sendable
    associatedtype ViewState: Sendable
    
    /// Maps a Domain state to a View State.
    /// - Parameter domain: The Domain to map to a View State.
    /// - Returns: The View State that is created from the given Domain.
    func reduce(from domain: Domain) -> ViewState
}
