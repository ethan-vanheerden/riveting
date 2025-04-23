//
//  MainViewController.swift
//  Searching
//
//  Created by Ethan on 4/17/25.
//

import UIKit
import SwiftUI
import Riveting

/// The base navigation controller for the app
final class MainViewNavigationController: UINavigationController {
    init() {
        let navigationRouter = SearchNavigationRouter()
        let view = SearchView(navigationRouter: navigationRouter)
        
        let rootVC = UIHostingController(rootView: view)
        super.init(rootViewController: rootVC)
        
        self.navigationBar.prefersLargeTitles = true
        
        /// Sets this class as the navigation delegate
        navigationRouter.navigator = self
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        return nil
    }
}

// MARK: - SwiftUI Usable

struct MainViewController_SwiftUI: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> some UIViewController {
        return MainViewNavigationController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}
