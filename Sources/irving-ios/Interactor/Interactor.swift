//
//  Interactor.swift
//  irving-ios
//
//  Created by Ethan Van Heerden on 10/23/24.
//

import Foundation

public protocol Interactor {
    associatedtype DomainAction
    associatedtype DomainResult
    
    func interact(_: DomainAction) async -> DomainResult
}
