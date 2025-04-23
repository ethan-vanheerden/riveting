//
//  SearchView.swift
//  Searching
//
//  Created by Ethan Van Heerden on 2/22/25.
//

import SwiftUI
import Riveting

struct SearchView: NavigableView {
    @StateObject private var feature = SearchFeature()
    let navigationRouter: SearchNavigationRouter
    
    init(navigationRouter: SearchNavigationRouter) {
        self.navigationRouter = navigationRouter
    }
    
    var body: some View {
        Group {
            switch feature.viewState {
            case .loading:
                loadingView
            case .error(let message):
                errorView(message: message)
            case .loaded(let display):
                loadedView(display: display)
            }
        }
        .navigationTitle("Search")
    }
    
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .onAppear {
                    feature.send(.load)
                }
            Spacer()
        }
    }
    
    private func errorView(message: String) -> some View {
        VStack {
            Spacer()
            Text("⚠️")
                .font(.title2)
            Text(message)
            Button("Reload") {
                feature.send(.load)
            }
            .buttonStyle(.bordered)
            Spacer()
        }
    }
    
    private func loadedView(display: SearchDisplay) -> some View {
        VStack {
            searchResults(display: display)
        }
        .searchable(text: searchTextBinding(currentText: display.searchText))
        .onSubmit(of: .search) {
            feature.send(.toggleAlert(alert: .submitSearch, isOpen: true))
        }
        .onChange(of: display.searchText) { _, newValue in
            if newValue.isEmpty {
                feature.send(.clearSearch)
            }
        }
        .alert(
            isOpen: alertBinding(alert: display.presentedAlert),
            alertState: display.searchAlert,
            primaryAction: { feature.send(.submitSearch) },
            secondaryAction: {
                feature.send(.toggleAlert(alert: .submitSearch, isOpen: false))
                feature.send(.clearSearch)
            }
        )
    }
    
    @ViewBuilder
    private func searchResults(display: SearchDisplay) -> some View {
        switch display.searchResults {
        case .loading:
            ProgressView()
        case .loaded(let searchResults):
            if searchResults.isEmpty {
                emptySearchResults
            } else {
                List {
                    ForEach(Array(searchResults.enumerated()), id: \.offset) { _, result in
                        Button {
                            navigate(.detail(for: result))
                        } label: {
                            Text(result)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .listStyle(.insetGrouped)
            }
        case .error(let message):
            searchErrorView(message: message)
        }
    }
    
    private var emptySearchResults: some View {
        VStack {
            Spacer()
            Text("Uh oh, no search results!")
                .font(.headline)
            Button("Clear Search") {
                feature.send(.clearSearch)
            }
            .buttonStyle(.bordered)
            Spacer()
        }
    }
    
    private func searchErrorView(message: String?) -> some View {
        VStack {
            Spacer()
            if let message {
                Text(message)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            Button("Clear Search") {
                feature.send(.clearSearch)
            }
            .buttonStyle(.bordered)
            .padding(.top, 8)
            Spacer()
        }
    }
    
    // MARK: - Bindings
    
    private func searchTextBinding(currentText: String) -> Binding<String> {
        Binding {
            currentText
        } set: { newText in
            feature.send(.updateSearchText(to: newText))
        }
    }
    
    private func alertBinding(alert: SearchAlert?) -> Binding<Bool> {
        Binding {
            alert != nil
        } set: { isOpen in
            guard let alert else { return }
            feature.send(.toggleAlert(alert: alert, isOpen: isOpen))
        }
    }
}

/// This extension serves to exemplify the benefits of having a Reducer to reduce the domain a view state. Many features can have an alert state,
/// but have a different domain representation. They can all share this same function extension though because of the view state's abstraction
/// of the domain layer,.
extension View {
    @ViewBuilder
    func alert(
        isOpen: Binding<Bool>,
        alertState: AlertViewState,
        primaryAction: @escaping () -> Void,
        secondaryAction: @escaping () -> Void
    ) -> some View {
        self
            .alert(alertState.title, isPresented: isOpen) {
                Button(alertState.primaryButtonTitle) {
                    primaryAction()
                }
                Button(alertState.secondaryButtonTitle, role: .cancel) {
                    secondaryAction()
                }
            }
    }
}
