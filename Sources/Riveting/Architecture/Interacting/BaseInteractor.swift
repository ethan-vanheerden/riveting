//
//  BaseInteractor.swift
//  Riveting
//
//  Created by Ethan Van Heerden on 3/22/25.
//

/// A base implementation of the `Interacting` protocol that provides common functionality
/// for domain state management.
///
/// This class handles:
/// - Maintaining the current domain state.
/// - Broadcasting domain updates through an `AsyncStream`.
/// - Providing a mechanism for safely updating the domain.
///
/// Subclasses should override the `interact(with:)` method to implement specific business logic for received `Action`s.
open class BaseInteractor<Action, Domain>: Interacting {
    public typealias Stream = AsyncStream<Domain>
    
    public var domain: Domain
    public let domainStream: Stream
    private let continuation: Stream.Continuation
    private var task: Task<Void, Never>?
    
    /// Initializes a new interactor with the specified initial domain state.
    ///
    /// The initializer sets up the `AsyncStream` for domain updates and immediately
    /// yields the initial domain as the first value in the stream.
    ///
    /// - Parameter initialDomain: The initial state of the domain model.
    public init(initialDomain: Domain) {
        domain = initialDomain
        (self.domainStream, self.continuation) = AsyncStream.makeStream(of: Domain.self)
        
        // Send the initial Domain at the start
        continuation.yield(initialDomain)
    }
    
    deinit {
        continuation.finish()
        task?.cancel()
    }
    
    /// Updates the domain state using the provided closure.
    ///
    /// This method:
    /// 1. Creates a mutable copy of the current domain.
    /// 2. Applies the update function to modify the copy.
    /// 3. Assigns the updated copy as the new domain.
    /// 4. Broadcasts the new domain to all subscribers.
    ///
    /// - Parameter update: A closure that modifies the domain state.
    public func updateDomain(_ update: (inout Domain) -> Void) {
        var newDomain = domain
        update(&newDomain)
        domain = newDomain
        
        continuation.yield(newDomain)
    }
    
    
    @discardableResult
    // Returns the task in case the caller wants to store it and cancel it
    public func updateDomain(_ update: @escaping (inout Domain) async -> Void) -> Task<Void, Never> {
        return Task {
            var newDomain = domain
            await update(&newDomain)
            domain = newDomain
            
            continuation.yield(newDomain)
        }
    }
    
    /// This is a placeholder implementation that must be overridden by subclasses.
    open func interact(with action: Action) {
        fatalError("Subclasses must implement interact(with:)")
    }
}
