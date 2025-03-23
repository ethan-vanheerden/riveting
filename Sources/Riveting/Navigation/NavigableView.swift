//
//  NavigableView.swift
//  Riveting
//
//  Created by Ethan Van Heerden on 3/9/25.
//

import SwiftUI

/// A View that can either be navigated to and/or away from using a specified `NavigationRouter`.
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
