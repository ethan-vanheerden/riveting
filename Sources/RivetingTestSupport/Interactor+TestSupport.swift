//
//  Interactor+TestSupport.swift
//  Riveting
//
//  Created by Ethan on 4/20/25.
//

import Riveting
import Foundation

public extension Interacting {
    
    /// Collects and returns the specified number of domains emitted by this Interator's stream of domains.
    /// **NOTE**: This function is greedy, it will return the first `count` of domains event if more domains are emitted.
    /// - Parameters:
    ///   - count: The number of domains to collect.
    ///   - timeout: The timeout (in seconds) to collect the number of specified domains.
    /// - Returns: An array of the collected domains.
    func collect(
        _ count: Int,
        performing actions: [Action],
        timeout: TimeInterval = 1
    ) async throws -> [Domain] {
        return try await withTimeout(seconds: timeout) {
            return try await withThrowingTaskGroup(of: [Domain].self) { group in
                // Child task to listen for domain state updates
                group.addTask {
                    var collectedDomains = [Domain]()
                    var iterator = domainStream.makeAsyncIterator()
                    
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
                    for action in actions {
                        interact(with: action)
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

enum InteractingTestError: Error {
    case unfulfilled(with: [Any], expectedCount: Int)
    
    var description: String {
        switch self {
        case let .unfulfilled(collectedDomains, expectedCount):
            return """
Interactor collected \(collectedDomains.count) domains, expected \(expectedCount):\n
\t\(collectedDomains.map { "\($0)\n"})
"""
        }
    }
}

