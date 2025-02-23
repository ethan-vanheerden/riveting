//
//  NavigationRouter.swift
//  irving-ios
//
//  Created by Ethan Van Heerden on 10/28/24.
//

/// Triggers custom actions based on navigation events which we send.
public protocol NavigationRouter {
    associatedtype Event
    
    var navigator: Navigator? { get set}
    
    /// Performs a custom action when a navigation event is received.
    /// - Parameter event: The navigation event which should trigger some navigation
    func navigate(_ event: Event)
}
