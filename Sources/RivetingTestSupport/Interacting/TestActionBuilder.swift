//
//  TestActionBuilder.swift
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

public func buildTestActions<Interactor>(@TestActionBuilder<Interactor> testActions: () -> [TestAction<Interactor>]) -> [TestAction<Interactor>] where Interactor: Interacting {
    testActions()
}


/// A result builder for constructing a series of serial `TestActions` to run when testing an interactor.
@resultBuilder
public struct TestActionBuilder<I: Interacting> {
    // Combines multiple expressions into an array
    public static func buildBlock(_ components: TestAction<I>...) -> [TestAction<I>] {
        components
    }
    
    public static func buildExpression(_ expression: I.Action) -> TestAction<I> {
        .action(expression)
    }
    
    public static func buildExpression(_ expression: TestAction<I>) -> TestAction<I> {
        expression
    }
    
    public static func buildOptional(_ component: [TestAction<I>]?) -> [TestAction<I>] {
        component ?? []
    }
    
    public static func buildEither(first component: [TestAction<I>]) -> [TestAction<I>] {
        component
    }
    
    public static func buildEither(second component: [TestAction<I>]) -> [TestAction<I>] {
        component
    }
    
    public static func buildArray(_ components: [[TestAction<I>]]) -> [TestAction<I>] {
        components.flatMap { $0 }
    }
}
