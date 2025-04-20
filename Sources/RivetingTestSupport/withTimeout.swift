//
//  withTimeout.swift
//  Riveting
//
//  Created by Ethan on 4/20/25.
//

import Foundation

/// Performs a unit of asynchronous work with a timeout.
/// - Parameters:
///   - seconds: The number of seconds until a timeout error is thrown.
///   - perform: The unit of work to perform.
///   - onTimeout: Closure to execute on timeout.
/// - Throws: When the perform closure throws, or when a timeout-releated error occurs.
/// - Returns: The returning type of the `perform` closure, if any.
public func withTimeout<Result>(
    seconds: TimeInterval,
    perform: @escaping @Sendable () async throws -> Result,
    onTimeout: @escaping @Sendable () async throws -> Void = { }
) async throws -> Result {
    return try await withThrowingTaskGroup(of: Result.self) { group in
        // Work task
        group.addTask {
            try await perform()
        }
        
        // Timeout task
        group.addTask {
            guard seconds > 0 else {
                throw WithTimeoutError.invalidTimeout
            }
            
            try await Task.sleep(for: .seconds(seconds))
            
            try Task.checkCancellation()
            throw WithTimeoutError.timedOut
        }
        
        do {
            guard let result = try await group.next() else {
                throw WithTimeoutError.noReturnedValue
            }
            
            group.cancelAll()
            
            return result
        } catch let error as WithTimeoutError {
            if case .timedOut = error {
                try await onTimeout()
            }
            
            throw error
        }
    }
}

enum WithTimeoutError: Error {
    case invalidTimeout
    case timedOut
    case noReturnedValue
}
