//
//  Feature.swift
//  Riveting
//
//  Created by Ethan Van Heerden on 2/22/25.
//

import SwiftUI

/// Defined a feature component in a unidirectional data flow architecture.
///
/// Features connect views to business logic by:
/// - Processing view actions through an `Interacting` type.
/// - Transforming domain models to view states via a `Reducing` type.
/// - Publishing view state changes to views.
///
public protocol Feature: ObservableObject {
    /// The type representing the UI state for rendering views.
    associatedtype ViewState
    
    /// The `Interacting` type responsible for processing actions and managing domain state.
    associatedtype Interactor: Interacting
    
    /// The `Reducing` type responsible for transforming domain models into view states.
    associatedtype Reducer: Reducing
    
    /// The View State contains rendering information for the View.
    /// The property is defined as `@MainActor` to ensure that any View
    /// updates occur on the main thread.
    @MainActor var viewState: ViewState { get }
    
    /// The Interactor this feature uses to react to View events to produce a new Domain.
    var interactor: Interactor { get }
    
    /// The Reducer this feature uses to map a new Domain to a new View State.
    var reducer: Reducer { get }
    
    /// Send an event from the View to trigger a reaction which updates the View State.
    /// - Parameter action: The event fired from the View.
    func send(_ action: Interactor.Action)
}
