//
//  Status.swift
//  Riveting
//
//  Created by Ethan Van Heerden on 3/1/25.
//

/// Represents a type that can have a loading, loaded, and error status states.
public enum Status<Value> {
    case loading
    case loaded(Value)
    case error(String?)
}
