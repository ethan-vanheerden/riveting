//
//  NavigationRouter.swift
//  Riveting
//
//  Created by Ethan Van Heerden on 10/28/24.
//

/// Handles navigation logic by responding to navigation events and delegating UI changes to a Navigator.
///
/// The NavigationRouter is responsible for:
/// - Defining the navigation events that can occur in a feature
/// - Implementing the business logic for each navigation event
/// - Delegating the actual UI navigation operations to a Navigator
///
/// This separation allows for:
/// - Cleaner view code that doesn't need to know navigation implementation details
/// - More testable navigation logic
/// - The ability to reuse navigation patterns across different features
///
/// NavigationRouters typically work with NavigableViews to provide a complete navigation solution.
public protocol NavigationRouter {
    associatedtype Event
    
    /// The Navigator that the actual navigation events are delegated to.
    var navigator: Navigator? { get set }
    
    /// Performs a custom action when a navigation event is received.
    /// - Parameter event: The navigation event which should trigger some navigation.
    func navigate(_ event: Event)
}
