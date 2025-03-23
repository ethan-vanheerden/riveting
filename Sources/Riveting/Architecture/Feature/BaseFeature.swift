//
//  BaseFeature.swift
//  Riveting
//
//  Created by Ethan Van Heerden on 3/22/25.
//

import SwiftUI

/// A base implementation of the `Feature` protocol that provides standard functionality
/// for connecting interactors and reducers in a unidirectional data flow architecture.
///
/// This class handles:
/// - Setting up bindings between the interactor and reducer.
/// - Automatically updating view state when domain changes occur.
/// - Threading concerns by ensuring view updates happen on the main thread.
/// - Proper cleanup of async tasks.
open class BaseFeature<Interactor, Reducer>: Feature where Interactor: Interacting,
                                                                Reducer: Reducing,
                                                                Interactor.Domain == Reducer.Domain {
    public typealias ViewState = Reducer.ViewState
    
    /// The current view state for rendering the UI.
    /// Published to enable SwiftUI's reactive updates.
    /// Updates are confined to the main thread via MainActor isolation.
    @MainActor @Published public private(set) var viewState: ViewState
    
    public let interactor: Interactor
    public let reducer: Reducer
    
    /// Task that observes domain changes from the interactor.
    private var task: Task<Void, Never>?
    
    /// Initializes a new feature with the specified interactor and reducer.
    ///
    /// During initialization, the feature:
    /// 1. Sets the initial view state based on the interactor's current domain.
    /// 2. Sets up bindings to react to future domain changes.
    ///
    /// - Parameters:
    ///   - interactor: The interactor that will process actions from the view.
    ///   - reducer: The reducer that will transform domain models into view states.
    public init(interactor: Interactor, reducer: Reducer) {
        self.interactor = interactor
        self.reducer = reducer
        self._viewState = Published(initialValue: reducer.reduce(from: interactor.domain))
        
        // Start observing domain changes immediately
        setupBindings()
    }
    
    deinit {
        task?.cancel()
    }
    
    /// Forwards an action to the interactor for processing. This method most likely will
    /// not need to be overriden.
    ///
    /// This method serves as the entry point for view events to trigger
    /// domain changes through the interactor.
    ///
    /// - Parameter action: The action representing a view event.
    public func send(_ action: Interactor.Action) {
        interactor.interact(with: action)
    }
    
    /// Sets up asynchronous observation of domain changes from the interactor.
    ///
    /// This method:
    /// 1. Cancels any existing observation task.
    /// 2. Creates a new task that listens for domain updates.
    /// 3. For each domain update, computes a new view state.
    /// 4. Updates the view state on the main thread.
    ///
    /// This binding creates the reactive loop that enables the unidirectional data flow.
    private func setupBindings() {
        task?.cancel()
        
        task = Task { [weak self] in
            guard let self = self else { return }
            
            for await domain in self.interactor.domainStream {
                let newViewState = self.reducer.reduce(from: domain)
                await MainActor.run {
                    self.viewState = newViewState
                }
            }
        }
    }
}
