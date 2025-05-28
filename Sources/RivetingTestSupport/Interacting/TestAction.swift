//
//  TestAction.swift
//  Riveting
//
//  Created by Ethan on 4/23/25.
//

import Riveting
import Foundation

// MARK: - TestAction

/// Represents an action that can be sent to an interactor during testing.
///
/// TestAction provides two types of actions:
/// - `action`: A regular interactor action that would be sent during normal operation
/// - `wait`: A special action that introduces a delay before the next action is sent
///
/// This enum is particularly useful for testing asynchronous behavior in interactors,
/// allowing tests to simulate real-world timing scenarios by introducing controlled delays
/// between actions.
///
/// Example:
/// ```swift
/// let actions: [TestAction<MyInteractor>] = [
///     .action(.loadData),
///     .wait(seconds: 0.5),
///     .action(.refresh)
/// ]
/// ```
public enum TestAction<Interactor> where Interactor: Interacting {
    case wait(seconds: TimeInterval)
    case action(Interactor.Action)
    
    public init(_ action: Interactor.Action) {
        self = .action(action)
    }
}
