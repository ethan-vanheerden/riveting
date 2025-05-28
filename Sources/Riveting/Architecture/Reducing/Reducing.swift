//
//  Reducing.swift
//  Riveting
//
//  Created by Ethan Van Heerden on 2/22/25.
//

/// A `Reducing` type transforms domain state into view state for rendering in the UI.
///
/// Reducers are responsible for:
/// - Converting domain models into view-specific data structures
/// - Filtering domain data to include only what the view needs
/// - Formatting data for presentation (e.g., date formatting, localization)
/// - Ensuring the view has exactly what it needs to render correctly
///
/// By separating the domain model from the view state, reducers help maintain a clean separation
/// of concerns and make the codebase more maintainable and testable.
public protocol Reducing {
    associatedtype Domain
    associatedtype ViewState
    
    /// Maps a Domain state to a View State. This is mainly used to abstract a model implementaiton
    /// into a type that *only* contains what the View needs to render.
    /// - Parameter domain: The Domain to map to a View State.
    /// - Returns: The View State that is created from the given Domain.
    func reduce(from domain: Domain) -> ViewState
}
