//
//  Interactor.swift
//  Riveting
//
//  Created by Ethan Van Heerden on 2/22/25.
//

/// An Interactoring type defines behavior to react to a specific View action and updates the underlying Domain
/// state of the feature. Generally, this is what updates our in-memory representation of our model.
protocol Interacting: Sendable {
    associatedtype Action: Sendable
    associatedtype Domain: Sendable
    
    /// Receives a View action and produces the updated Domain state.
    /// - Parameter action: The action fired from the View.
    /// - Returns: The updated Domain state triggered by the View action.
    func interact(with action: Action) -> Domain
}
