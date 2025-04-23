//
//  SearchFeature.swift
//  Searching
//
//  Created by Ethan Van Heerden on 3/9/25.
//

import Riveting

final class SearchFeature: BaseFeature<SearchInteractor, SearchReducer> {
    convenience init() {
        let interactor = SearchInteractor(initialDomain: .loading)
        let reducer = SearchReducer()
        
        self.init(interactor: interactor, reducer: reducer)
    }
}
