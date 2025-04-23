//
//  SearchNavigationRouter.swift
//  Searching
//
//  Created by Ethan on 4/17/25.
//

import Riveting
import Foundation

enum SearchNavigationEvent {
    case detail(for: String)
}

@MainActor
final class SearchNavigationRouter: NavigationRouter {
    weak var navigator: Navigator?
    
    func navigate(_ event: SearchNavigationEvent) {
        switch event {
        case .detail(for: let item):
            navigator?.push(DetailView(item: item), animated: true)
        }
    }
}
