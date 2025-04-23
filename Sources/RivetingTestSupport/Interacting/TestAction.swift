//
//  TestAction.swift
//  Riveting
//
//  Created by Ethan on 4/23/25.
//

import Riveting
import Foundation

// MARK: - TestAction

/// Represents an action an interactor can be sent during a testing environement. This is just the iteractor's
/// defined actions along with a `wait` actions which specifies a waiting period before it can be fired another action.
public enum TestAction<Interactor> where Interactor: Interacting {
    case wait(seconds: TimeInterval)
    case action(Interactor.Action)
    
    public init(_ action: Interactor.Action) {
        self = .action(action)
    }
    
    static func build(@TestActionBuilder<Interactor> testActions: () -> [TestAction<Interactor>]) -> [TestAction<Interactor>] {
        testActions()
    }
}
