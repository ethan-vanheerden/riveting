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
    func collect(_ count: Int, timeout: TimeInterval = 1) async throws -> [Domain] {
        var task: Task<Void, Never>?
        return try await withTimeout(seconds: timeout) {
            return try await withCheckedThrowingContinuation { continuation in
                task = Task {
                    var collectedDomains = [Domain]()
                    var iterator = self.domainStream.makeAsyncIterator()
                    
                    while collectedDomains.count < count {
                        guard let domain = await iterator.next() else {
                            continuation.resume(
                                throwing: InteractingTestError.unfulfilled(with: collectedDomains, expectedCount: count)
                            )
                            return
                        }
                        
                        collectedDomains.append(domain)
                        
                        if collectedDomains.count == count {
                            continuation.resume(returning: collectedDomains)
                            return
                        }
                    }
                }
            }
        } onTimeout: {
            task?.cancel()
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

