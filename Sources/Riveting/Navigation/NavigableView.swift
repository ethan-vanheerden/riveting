//
//  NavigableView.swift
//  Riveting
//
//  Created by Ethan Van Heerden on 3/9/25.
//

import SwiftUI

/// A View that can be navigated to and/or away from using a specified `NavigationRouter`.
///
/// NavigableView provides a standardized way to handle navigation within the RIV architecture.
/// It encapsulates navigation logic and delegates the actual navigation implementation to a router.
///
/// By conforming to this protocol, views can:
/// - Maintain a reference to a navigation router
/// - Trigger navigation events through a consistent interface
/// - Separate navigation logic from view rendering logic
///
/// This approach makes navigation more testable and allows for different navigation implementations
/// without changing the view code.
public protocol NavigableView: View {
    associatedtype Router: NavigationRouter
    
    /// The `NavigationRouter` used to perform navigation.
    var navigationRouter: Router { get }
    
    /// Performs a navigation event in this view.
    /// - Parameter event: The navigation event which should trigger some navigation.
    func navigate(_ event: Router.Event)
}

public extension NavigableView {
    func navigate(_ event: Router.Event) {
        navigationRouter.navigate(event)
    }
}
