# Riveting: RIV Architecture for iOS + macOS

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%2017%20%7C%20macOS%2014-blue.svg)](https://developer.apple.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Riveting is a Swift implementation of the RIV (Reducer, Interactor, View) architecture for iOS applications, leveraging Swift's AsyncStream for reactive state management.

## Overview

RIV is a unidirectional data flow architecture that separates concerns into three main components.

### Core Components

- **Reducer**: Transforms domain models into view states
- **Interactor**: Processes actions and manages domain state
- **View**: Renders the UI based on view state and sends actions

This separation creates a clean, testable architecture with a predictable data flow:

1. The View sends actions to the Interactor
2. The Interactor processes actions and updates the domain state
3. The Reducer transforms the domain state into view state
4. The View renders based on the new view state

## Key Features

- **Unidirectional Data Flow**: Predictable state management with a clear flow of data
- **Async/Await Support**: Built on Swift's modern concurrency model
- **Type Safety**: Leverages Swift's strong type system for compile-time safety
- **Testability**: Components designed for easy unit testing
- **SwiftUI Integration**: Seamless integration with SwiftUI's declarative UI paradigm
- **UIKit Support**: Also works with UIKit through the Navigator protocol

## Installation

### Swift Package Manager

Add Riveting to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/username/Riveting.git", from: "1.0.0")
]
```

Then add the dependency to your target:

```swift
.target(
    name: "YourApp",
    dependencies: ["Riveting"]
)
```

For testing support, add the RivetingTestSupport package _only_ to your test target:

```swift
.testTarget(
    name: "YourAppTests",
    dependencies: ["Riveting", "RivetingTestSupport"]
)
```

## Usage

### Creating a Feature

A feature in RIV consists of three main components:

1. **Domain Model**: Represents the state of your feature
2. **Interactor**: Processes actions and updates the domain
3. **Reducer**: Transforms domain state to view state
4. **Feature**: Connects the interactor and reducer to the view

```swift
// 1. Define your domain model
struct CounterDomain {
    var count: Int = 0
}

// 2. Define actions
enum CounterAction {
    case increment
    case decrement
    case reset
}

// 3. Create an interactor
class CounterInteractor: BaseInteractor<CounterAction, CounterDomain> {
    override func interact(with action: CounterAction) {
        switch action {
        case .increment:
            updateDomain { domain in
                domain.count += 1
            }
        case .decrement:
            updateDomain { domain in
                domain.count -= 1
            }
        case .reset:
            updateDomain { domain in
                domain.count = 0
            }
        }
    }
}

// 4. Create a reducer
struct CounterReducer: Reducing {
    func reduce(from domain: CounterDomain) -> CounterViewState {
        CounterViewState(
            count: domain.count,
            isNegative: domain.count < 0
        )
    }
}

// 5. Define your view state
struct CounterViewState {
    let count: Int
    let isNegative: Bool
}

// 6. Create a feature
class CounterFeature: BaseFeature<CounterInteractor, CounterReducer> {
    // BaseFeature provides all the necessary functionality
}
```

### Using the Feature in a SwiftUI View

```swift
struct CounterView: View {
    @StateObject private var feature = CounterFeature(
        interactor: CounterInteractor(initialDomain: CounterDomain()),
        reducer: CounterReducer()
    )
    
    var body: some View {
        VStack {
            Text("Count: \(feature.viewState.count)")
                .foregroundColor(feature.viewState.isNegative ? .red : .primary)
            
            HStack {
                Button("Decrement") {
                    feature.send(.decrement)
                }
                
                Button("Reset") {
                    feature.send(.reset)
                }
                
                Button("Increment") {
                    feature.send(.increment)
                }
            }
        }
        .padding()
    }
}
```

## Navigation

Riveting is designed to be flexible with your navigation choices:

### Pure SwiftUI Navigation

You can use SwiftUI's native navigation components (NavigationStack, NavigationLink, etc.) directly with Riveting features:

```swift
struct MainView: View {
    @StateObject private var feature = CounterFeature(
        interactor: CounterInteractor(initialDomain: CounterDomain()),
        reducer: CounterReducer()
    )
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Count: \(feature.viewState.count)")
                
                Button("Increment") {
                    feature.send(.increment)
                }
                
                NavigationLink("Go to Details") {
                    DetailView(count: feature.viewState.count)
                }
            }
        }
    }
}
```

### UIKit-Based Navigation

If you prefer or need to use a UIKit-based navigation stack, Riveting provides NavigationRouter and NavigableView components:

```swift
// Define navigation events
enum ProfileNavigationEvent {
    case showSettings
    case showDetails(userId: String)
    case dismiss
}

// Create a navigation router
class ProfileNavigationRouter: NavigationRouter {
    weak var navigator: Navigator?
    
    func navigate(_ event: ProfileNavigationEvent) {
        switch event {
        case .showSettings:
            navigator?.push(SettingsView(), animated: true)
        case .showDetails(let userId):
            navigator?.push(UserDetailsView(userId: userId), animated: true)
        case .dismiss:
            navigator?.dismiss(animated: true)
        }
    }
}

// Use in a view
struct ProfileView: NavigableView {
    let navigationRouter: ProfileNavigationRouter
    
    var body: some View {
        VStack {
            Button("Settings") {
                navigate(.showSettings)
            }
            
            Button("User Details") {
                navigate(.showDetails(userId: "123"))
            }
            
            Button("Dismiss") {
                navigate(.dismiss)
            }
        }
    }
}
```

## Examples

The repository includes an example project demonstrating the RIV architecture in action:

- **Searching**: A search feature that demonstrates async data loading, error handling, and navigation

To run the examples, clone the repository and open the example project in Xcode.

## Testing

Riveting includes test support utilities to make testing your features easier:

```swift
import Testing
import Riveting
import RivetingTestSupport

struct CounterInteractorTests {
    private let sut: CounterInteractor
    
    init() {
        self.sut = CounterInteractor(initialDomain: CounterDomain(count: 0))
    }
    
    @Test
    func increment() {
        sut.interact(with: .increment)
        #expect(sut.domain.count == 1)
    }
    
    @Test
    func decrement() {
        sut.interact(with: .decrement)
        #expect(sut.domain.count == -1)
    }
    
    @Test
    func reset() {
        // First increment to change the initial state
        sut.interact(with: .increment)
        #expect(sut.domain.count == 1)
        
        // Then reset
        sut.interact(with: .reset)
        #expect(sut.domain.count == 0)
    }
    
    @Test
    func multipleActions() async throws {
        // For complex sequences where you need to capture intermediate states,
        // use the collect utility
        let emittedDomains = try await sut.collect(
            3,
            performing: [
                .action(.increment),
                .action(.increment),
                .action(.decrement)
            ]
        )
        
        let expectedDomains: [CounterDomain] = [
            CounterDomain(count: 1),
            CounterDomain(count: 2),
            CounterDomain(count: 1)
        ]
        
        #expect(emittedDomains == expectedDomains)
    }
}
```

## License

Riveting is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
