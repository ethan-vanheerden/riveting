//
//  WIP.swift
//  irving-ios
//
//  Created by Ethan Van Heerden on 12/31/24.
//

import SwiftUI

protocol Interacting: Sendable {
    associatedtype Action: Sendable
    associatedtype Domain: Sendable
    
    func interact(with action: Action) -> Domain
}

protocol Reducing: Sendable {
    associatedtype Domain: Sendable
    associatedtype ViewState: Sendable
    
    func reduce(from domain: Domain) -> ViewState
}

protocol Feature: ObservableObject {
    associatedtype ViewState
    associatedtype Interactor: Interacting
    associatedtype Reducer: Reducing
    
    @MainActor var viewState: ViewState { get set }
    
    var interactor: Interactor { get }
    var reducer: Reducer { get }
    
    // This should update the view state
    func send(action: Interactor.Action) async
}

extension Feature where Interactor.Domain == Reducer.Domain,
                        Reducer.ViewState == ViewState {
    
    @MainActor func send(action: Interactor.Action) async {
        
        let interactor = self.interactor
        let reducer = self.reducer
        // These can run off the main thread
        let domain = await Task.detached(priority: .userInitiated) {
            interactor.interact(with: action)
        }.value
        let viewState = await Task.detached(priority: .userInitiated) {
            reducer.reduce(from: domain)
        }.value
        
        // Now we're already on the main thread thanks to @MainActor
        self.viewState = viewState
    }
}


enum MyAction {
    case load
    case updateText(to: String)
}

struct MyModel {
    let name: String
}

enum MyDomain {
    case loading
    case error
    case loaded(MyModel)
}

struct MyDisplay {
    let name: String
}

enum MyViewState {
    case loading
    case error
    case loaded(MyDisplay)
}

struct MyInteractor: Interacting {
    func interact(with action: MyAction) -> MyDomain {
        return .loading
    }
}

struct MyReducer: Reducing {
    func reduce(from domain: MyDomain) -> MyViewState {
        return .loading
    }
}

final class MyFeature: Feature {
    @Published var viewState: MyViewState = .loading
    let interactor = MyInteractor()
    let reducer = MyReducer()
}
