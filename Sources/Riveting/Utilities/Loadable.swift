//
//  Loadable.swift
//  Riveting
//
//  Created by Ethan Van Heerden on 3/1/25.
//

/// Represents a type that can have a loadable state until it obtains a real value.
protocol Loadable {
    associatedtype Value
    
    var value: LoadableValue<Value> { get set }
}

/// A value that needs to be loaded.
enum LoadableValue<Value> {
    case loading
    case loaded(Value)
}
