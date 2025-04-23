//
//  SearchReducer.swift
//  Searching
//
//  Created by Ethan Van Heerden on 3/9/25.
//

import Riveting

// MARK: - Displays

struct SearchDisplay {
    let searchText: String
    let searchResults: Status<[String]>
    let searchAlert: AlertViewState
    let presentedAlert: SearchAlert?
}

enum SearchAlert {
    case submitSearch
}

/// This type is example of why the Reducer mapping is useful.
/// The Interactor need not know the UI representation of an alert.
struct AlertViewState {
    let title: String
    let subTitle: String
    let primaryButtonTitle: String
    let secondaryButtonTitle: String
}

// MARK: - SearchViewState

enum SearchViewState {
    case loading
    case error(String)
    case loaded(SearchDisplay)
}

struct SearchReducer: Reducing {
    func reduce(from domain: SearchDomain) -> SearchViewState {
        switch domain {
        case .loading:
            return .loading
        case .error:
            return .error("Something went wrong, please try again later 😅")
        case .loaded(let model):
            let display = display(for: model)
            return .loaded(display)
        case let .alert(alert, model):
            let display = display(for: model, presentedAlert: alert)
            return .loaded(display)
        }
    }
}

private extension SearchReducer {
    func display(for model: SearchModel, presentedAlert: SearchAlert? = nil) -> SearchDisplay {
        let searchAlert = AlertViewState(
            title: "Search for \(model.searchText)?",
            subTitle: "This will filter the superhero list.",
            primaryButtonTitle: "Search",
            secondaryButtonTitle: "Cancel"
        )
        
        return SearchDisplay(
            searchText: model.searchText,
            searchResults: model.searchResults,
            searchAlert: searchAlert,
            presentedAlert: presentedAlert
        )
    }
}
