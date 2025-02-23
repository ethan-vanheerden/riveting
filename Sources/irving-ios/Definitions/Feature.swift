//
//  Feature.swift
//  irving-ios
//
//  Created by Ethan Van Heerden on 2/22/25.
//

import Foundation
import SwiftUI

/// Represents a feature which reacts to user events and updates a View State.
/// This type acts as the glue for a feature by connecting an Interactor and a Reducer,
/// as well as publishing an updated View State.
protocol Feature: ObservableObject {
    associatedtype ViewState
    associatedtype Interactor: Interacting
    associatedtype Reducer: Reducing
    
    /// The View State contains rendering information for the View.
    /// The property is defined as `@MainActor` to ensure that any View
    /// updates occur on the main thread.
    @MainActor var viewState: ViewState { get set }
    
    /// The Interactor this feature uses to react to View events to produce a new Domain.
    var interactor: Interactor { get }
    
    /// The Reducer this feature uses to map a new Domain to a new View State.
    var reducer: Reducer { get }
    
    /// Send an event fro the View to trigger a reaction which updates the View State.
    /// - Parameter action: The event fired from the View.
    func send(action: Interactor.Action) async
}

/// This is a convenience extension which should be automatically adapted by almost all
/// features. The associated types in the Feature, Interactor, and Reducer should appropriately
/// align, which allows a simple implementation of the `send(action:)` function.
///
/// If your Feature can't utilize this extension, you should double check your associated types.
extension Feature where Interactor.Domain == Reducer.Domain,
                        Reducer.ViewState == ViewState {
    
    @MainActor func send(action: Interactor.Action) async {
        
        let interactor = self.interactor
        let reducer = self.reducer
        // These can run off the main thread
        let domain = await Task.detached(priority: .userInitiated) {
            interactor.interact(with: action)
        }.value
        let viewState = await Task.detached(priority: .userInitiated) {
            reducer.reduce(from: domain)
        }.value
        
        self.viewState = viewState
    }
}
