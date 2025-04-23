//
//  Interactor+TestSupport.swift
//  Riveting
//
//  Created by Ethan on 4/20/25.
//

import Riveting
import Foundation

// MARK: - Interacting+TestSupport

public extension Interacting {
    
    /// Collects and returns the specified number of domains emitted by this Interator's stream of domains.
    /// **NOTE**: This function is greedy, it will return the first `count` of domains even if more domains would be emitted in the future.
    /// - Parameters:
    ///   - count: The number of domains to collect.
    ///   - actions: The list of `TestAction`s to send to this interactor in the given order.
    ///              This is either one of the interactor's defined actions, or a specified wait period before firing the next action.
    ///   - includeFirst: Whether or not to include the first emitted state in the returned domains array.
    ///                   This is in the event you want to avoid collecting a value that is published upon
    ///                   initialization, and just want to collect values emitted after sending `actions`.
    ///                   Default value is false.
    ///   - timeout: The timeout (in seconds) to collect the number of specified domains.
    /// - Returns: An array of the collected domains.
    func collect(
        _ count: Int,
        performing actions: [TestAction<Self>],
        includeFirst: Bool = false,
        timeout: TimeInterval = 1
    ) async throws -> [Domain] {
        guard count > 0 else {
            throw InteractingTestError.invalidCount(count)
        }
        
        return try await withTimeout(seconds: timeout) {
            return try await withThrowingTaskGroup(of: [Domain].self) { group in
                // Child task to listen for domain state updates
                group.addTask {
                    var collectedDomains = [Domain]()
                    var iterator = domainStream.makeAsyncIterator()
                    
                    if !includeFirst {
                        _ = await iterator.next()
                    }
                    
                    while collectedDomains.count < count {
                        guard let nextDomain = await iterator.next() else {
                            throw InteractingTestError.unfulfilled(
                                with: collectedDomains,
                                expectedCount: count
                            )
                        }
                        collectedDomains.append(nextDomain)
                    }
                    
                    return collectedDomains
                }
                
                // Child task to send the actual events
                group.addTask {
                    for testAction in actions {
                        switch testAction {
                        case .wait(let seconds):
                            try await Task.sleep(for: .seconds(seconds))
                            continue
                        case .action(let action):
                            interact(with: action)
                        }
                    }
                    return [] // Signify end of the child task
                }
                
                var emittedDomains = [Domain]()
                for try await domains in group {
                    if !domains.isEmpty {
                        group.cancelAll()
                        emittedDomains = domains
                        break
                    }
                }
                
                guard emittedDomains.count == count else {
                    throw InteractingTestError.unfulfilled(
                        with: emittedDomains,
                        expectedCount: count
                    )
                }
                
                return emittedDomains
            }
        }
    }
}

// MARK: - InteractingTestError

enum InteractingTestError: Error {
    case invalidCount(Int)
    case unfulfilled(with: [Any], expectedCount: Int)
    
    var description: String {
        switch self {
        case .invalidCount(let count):
            "Received in invalid count: \(count)"
        case let .unfulfilled(collectedDomains, expectedCount):
"""
Interactor collected \(collectedDomains.count) domains, expected \(expectedCount):\n
\t\(collectedDomains.map { "\($0)\n"})
"""
        }
    }
}
