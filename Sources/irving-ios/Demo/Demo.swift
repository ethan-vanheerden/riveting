//
//  Demo.swift
//  irving-ios
//
//  Created by Ethan Van Heerden on 10/28/24.
//

import SwiftUI

enum MyViewEvent: Equatable {
    case makeLoad
    case makeLoading
    case makeError
}

enum MyViewState {
    case loading
    case loaded
    case error
}

@Observable
final class MyViewModel: ViewModel {
    private(set) var viewState: MyViewState = .loading
    private let interactor = MyInteractor()
    private let reducer = MyReducer()
    
    func send(_ event: MyViewEvent) async {
        switch event {
        case .makeLoad:
            await react(domainAction: .makeLoad)
        case .makeLoading:
            await react(domainAction: .makeLoading)
        case .makeError:
            await react(domainAction: .makeError)
        }
    }
    
    private func react(domainAction: MyDomainAction) async {
        let domainResult = await interactor.interact(domainAction)
        let newViewState = reducer.reduce(domainResult)
        viewState = newViewState
    }
}


enum MyDomainAction {
    case makeLoad
    case makeLoading
    case makeError
}

enum MyDomainResult {
    case loading
    case loaded
    case error
}


struct MyInteractor: Interactor {
    func interact(_ domainAction: MyDomainAction) async -> MyDomainResult {
        switch domainAction {
        case .makeLoad:
                .loaded
        case .makeLoading:
                .loading
        case .makeError:
                .error
        }
    }
}

struct MyReducer: Reducer {
    func reduce(_ domainResult: MyDomainResult) -> MyViewState {
        switch domainResult {
        case .loading:
                .loading
        case .loaded:
                .loaded
        case .error:
                .error
        }
    }
}


struct MyView<VM: ViewModel>: View where VM.ViewState == MyViewState,
                                         VM.ViewEvent == MyViewEvent {
    private var viewModel: VM
    
    init(viewModel: VM) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        switch viewModel.viewState {
        case .loading:
            Text("Loading")
            ProgressView()
            Button("Make Loaded") {
                viewModel.send(.makeLoad)
            }
            Button("Make Error") {
                viewModel.send(.makeError)
            }
        case .error:
            Text("Error!")
            Button("Make Loading") {
                viewModel.send(.makeLoading)
            }
            Button("Make Loaded") {
                viewModel.send(.makeLoad)
            }
        case .loaded:
            Text("Loaded")
            Button("Make Loading") {
                viewModel.send(.makeLoading)
            }
            Button("Make Error") {
                viewModel.send(.makeError)
            }
        }
    }
}
