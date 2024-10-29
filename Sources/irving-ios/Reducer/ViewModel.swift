//
//  ViewModel.swift
//  irving-ios
//
//  Created by Ethan Van Heerden on 10/23/24.
//

import Foundation
import SwiftUI
import Combine

/// View models which publish a state for views to observe.
/// Mark as `@MainActor` to ensure updates to view state and thus the UI happen on the main thread.
/// It is your responsibility to setup and run an operation on a background thread if needed.
@MainActor
public protocol ViewModel: Sendable {
    /// The published state that views will subscribe to
    associatedtype ViewState: Sendable
    /// The events that a `View` can send to its `ViewModel`
    associatedtype ViewEvent: Sendable
    
    /// The published state that views will subscribe to
    var viewState: ViewState { get }
    
    /// Triggers a custom action based on the event that the view sent to its view model.
    /// - Parameter event: The event that the view sent
    func send(_ event: ViewEvent) async
}

/// For use in a SwiftUI context
public extension ViewModel {
    func send(_ event: ViewEvent, priority: TaskPriority = .userInitiated) {
        Task(priority: .userInitiated) {
            await send(event)
        }
    }
}

//final class BasicMapper<Event>: EventMapper {
//    typealias InputEvent = Event
//    typealias OutputEvent = Event
//    
//}
//
//extension EventMapper where InputEvent  {
//    static func map(_ input: InputEvent) -> OutputEvent where InputEvent == OutputEvent {
//        return input
//    }
//}

extension ViewModel {
    
}

//extension ViewModel {
//    func send(_ event: Event) async where MyInteractor.DomainAction == DomainAction,
//                                            MyInteractor.DomainResult == DomainResult,
//                                            MyReducer.DomainResult == DomainResult,
//                                            MyReducer.ViewState == ViewState,
//                                            Mapper.InputEvent == Event,
//                                            Mapper.OutputEvent == DomainAction {
//        let domainAction = Mapper.map(event)
//        let domainResult = await interactor.interact(domainAction)
//        let newViewState = reducer.reduce(domainResult)
//        
//        await MainActor.run {
//            viewState = newViewState
//        }
//    }
//}


protocol Loadable {
    var isLoading: Bool { get set }
}
