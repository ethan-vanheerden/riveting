//
//  Loadable.swift
//  Riveting
//
//  Created by Ethan Van Heerden on 3/1/25.
//

/// Represents a type that can have a loadable state until it obtains a real value.
public enum Loadable<Value> {
    case loading
    case loaded(Value)
}
