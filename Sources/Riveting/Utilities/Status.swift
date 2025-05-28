//
//  Status.swift
//  Riveting
//
//  Created by Ethan Van Heerden on 3/1/25.
//

/// Represents a type that can have loading, loaded, and error status states.
///
/// The Status enum is a generic type that wraps a value and provides a way to represent
/// the different states that can occur during asynchronous operations:
///
/// - `loading`: Indicates that the operation is in progress and no value is available yet.
/// - `loaded`: Contains the successfully loaded value of type `Value`.
/// - `error`: Represents an error state, optionally containing an error message.
///
/// This type is particularly useful for managing UI states in features that involve
/// asynchronous data loading, such as network requests or database operations.
///
/// The enum conforms to Equatable when the wrapped Value type is Equatable.
public enum Status<Value> {
    case loading
    case loaded(Value)
    case error(String?)
}

extension Status: Equatable where Value: Equatable { /* no-op */ }
