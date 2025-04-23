//
//  SearchInteractor.swift
//  Searching
//
//  Created by Ethan Van Heerden on 3/9/25.
//

import Riveting

// MARK: - SearchAction

enum SearchAction {
    case load
    case updateSearchText(to: String)
    case toggleAlert(alert: SearchAlert, isOpen: Bool)
    case submitSearch
    case clearSearch
}

// MARK: - SearchModel

struct SearchModel: Equatable {
    var searchText: String
    var searchResults: Status<[String]>
}

// MARK: SearchDomain

enum SearchDomain: Equatable {
    case loading
    case error
    case loaded(SearchModel)
    case alert(alert: SearchAlert, model: SearchModel)
    
    var model: SearchModel? {
        switch self {
        case .loading:
            nil
        case .error:
            nil
        case .loaded(let model),
                .alert(_, let model):
            model
        }
    }
}

// MARK: - SearchInteractor

final class SearchInteractor: BaseInteractor<SearchAction, SearchDomain> {
    private var currentSearchTask: Task<Void, Never>?
    
    private let mockResults = [
        "Captain America",
        "Iron Man",
        "Black Widow",
        "Hulk",
        "Thor",
        "Hawkeye"
    ]
    
    override func interact(with action: SearchAction) {
        switch action {
        case .load:
            updateDomain { domain in
                let initialModel = SearchModel(
                    searchText: "",
                    searchResults: .loaded(mockResults)
                )
                domain = .loaded(initialModel)
            }
        case .updateSearchText(let newSearchText):
            guard var model = domain.model,
                  model.searchText != newSearchText else {
                return
            }
            
            updateDomain { domain in
                model.searchText = newSearchText
                domain = .loaded(model)
            }
        case let .toggleAlert(alert, isOpen):
            guard let model = domain.model else { return }
            
            updateDomain { domain in
                domain = isOpen ? .alert(alert: alert, model: model) : .loaded(model)
            }
        case .submitSearch:
            let mockResults = mockResults
            currentSearchTask?.cancel()
            
            updateDomain { domain in
                guard var model = domain.model else { return }
                
                model.searchResults = .loading
                
                domain = .loaded(model)
            }
            
            currentSearchTask = updateDomain { domain in
                guard var model = domain.model else { return }
                
                do {
                    // Simulate a network request
                    try await Task.sleep(for: .seconds(1))
                    
                    model.searchResults = .loaded(mockResults.filter {
                        $0.lowercased().contains(model.searchText.lowercased())
                    })
                    domain = .loaded(model)
                } catch {
                    model.searchResults = .error("Something went wrong, please try again later 😅")
                    domain = .loaded(model)
                }
            }
        case .clearSearch:
            updateDomain { domain in
                let resetModel = SearchModel(
                    searchText: "",
                    searchResults: .loaded(mockResults)
                )
                domain = .loaded(resetModel)
            }
        }
    }
}
