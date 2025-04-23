//
//  SearchInteractorTests.swift
//  Searching
//
//  Created by Ethan on 4/20/25.
//

import Testing
@testable import Searching
import RivetingTestSupport

struct SearchInteractorTests {
    private let sut: SearchInteractor
    private let mockData: [String] = [
        "Captain America",
        "Iron Man",
        "Black Widow",
        "Hulk",
        "Thor",
        "Hawkeye"
    ]
    private let loadedModel: SearchModel
    
    init() {
        self.loadedModel = .init(searchText: "", searchResults: .loaded(mockData))
        self.sut = SearchInteractor(initialDomain: .loaded(loadedModel))
    }
    
    @Test
    func load() async throws {
        let loadingSut = SearchInteractor(initialDomain: .loading)
        #expect(loadingSut.domain == .loading)
        loadingSut.interact(with: .load)
        #expect(
            loadingSut.domain == .loaded(
                .init(
                    searchText: "",
                    searchResults: .loaded(mockData)
                )
            )
        )
    }
    
    @Test
    func updateSearchText() async throws {
        sut.interact(with: .updateSearchText(to: "Captain"))
        #expect(
            sut.domain == .loaded(
                .init(
                    searchText: "Captain",
                    searchResults: .loaded(mockData)
                )
            )
        )
    }
    
    @Test
    func toggleAlertOpen() async throws {
        sut.interact(with: .toggleAlert(alert: .submitSearch, isOpen: true))
        #expect(
            sut.domain == .alert(
                alert: .submitSearch,
                model: loadedModel
            )
        )
    }
    
    @Test
    func toggleAlertClose() async throws {
        sut.interact(with: .toggleAlert(alert: .submitSearch, isOpen: true))
        sut.interact(with: .toggleAlert(alert: .submitSearch, isOpen: false))
        #expect(sut.domain == .loaded(loadedModel))
    }
    
    @Test
    func submitSearchSuccess() async throws {
        let emittedDomains = try await sut.collect(
            3,
            performing: [
                .action(.updateSearchText(to: "O")),
                .action(.submitSearch)
            ],
            timeout: 2
        )
        
        let expectedDomains: [SearchDomain] = [
            .loaded(
                .init(
                    searchText: "O",
                    searchResults: .loaded(mockData)
                )
            ),
            .loaded(
                .init(
                    searchText: "O",
                    searchResults: .loading
                )
            ),
            .loaded(
                .init(searchText: "O", searchResults: .loaded([
                    "Iron Man",
                    "Black Widow",
                    "Thor"
                ]))
            )
        ]
        
        #expect(emittedDomains == expectedDomains)
    }
    
    @Test
    func clearSearch() async throws {
        let emittedDomains = try await sut.collect(
            4,
            performing: [
                .action(.updateSearchText(to: "Captain")),
                .action(.submitSearch),
                .wait(seconds: 1.1),
                .action(.clearSearch)
            ],
            timeout: 2
        )
        
        let expectedDomains: [SearchDomain] = [
            .loaded(
                .init(
                    searchText: "Captain",
                    searchResults: .loaded(mockData)
                )
            ),
            .loaded(
                .init(
                    searchText: "Captain",
                    searchResults: .loading
                )
            ),
            .loaded(
                .init(searchText: "Captain", searchResults: .loaded([
                    "Captain America"
                ]))
            ),
            .loaded(
                .init(
                    searchText: "",
                    searchResults: .loaded(mockData)
                )
            )
        ]
        
        #expect(emittedDomains == expectedDomains)
    }
}
