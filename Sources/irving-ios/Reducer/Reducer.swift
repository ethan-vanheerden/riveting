//
//  Reducer.swift
//  irving-ios
//
//  Created by Ethan Van Heerden on 10/23/24.
//

public protocol Reducer {
    associatedtype DomainResult
    associatedtype ViewState
    
    func reduce(_: DomainResult) -> ViewState
}
