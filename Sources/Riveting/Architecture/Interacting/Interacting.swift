//
//  Interacting.swift
//  Riveting
//
//  Created by Ethan Van Heerden on 2/22/25.
//

/// An `Interacting` type defines behavior to react to a specific View action to update the underlying domain
/// state of the feature.
///
/// Interactors are responsible for:
/// - Processing actions from the view
/// - Updating the domain state based on those actions
/// - Broadcasting domain state changes to subscribers
/// - Encapsulating business logic and side effects
///
/// The interactor is a key component in the unidirectional data flow architecture, serving as the bridge
/// between user interactions and domain state changes.
public protocol Interacting {
    /// The type of action that can be sent to the interactor.
    associatedtype Action
    
    /// The domain model type that represents the current state.
    associatedtype Domain
    
    /// The current domain state.
    /// This property provides immediate access to the latest snapshot of the domain model.
    var domain: Domain { get }
    
    /// An asynchronous stream of domain state updates.
    /// Subscribers can use `for await` loops to receive state updates as they occur.
    var domainStream: AsyncStream<Domain> { get }

    /// Processes the specified action to update the domain state.
    /// - Parameter action: The action to process, typically representing a user
    ///   interaction or system event.
    func interact(with action: Action)
}
