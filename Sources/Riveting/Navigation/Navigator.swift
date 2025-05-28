//
//  Navigator.swift
//  Riveting
//
//  Created by Ethan Van Heerden on 10/28/24.
//

#if canImport(UIKit)
import UIKit
#endif
import SwiftUI

/// Handles the actual UI navigation operations delegated by a NavigationRouter.
///
/// The Navigator is responsible for:
/// - Executing UI-specific navigation operations like pushing, presenting, or dismissing views
/// - Providing a consistent interface for both UIKit and SwiftUI navigation
/// - Isolating navigation implementation details from business logic
///
/// By separating the navigation implementation (Navigator) from the navigation logic (NavigationRouter),
/// the RIV architecture achieves better testability and flexibility in how navigation is performed.
///
/// This protocol is marked with @MainActor to ensure all UI operations happen on the main thread.
@MainActor
public protocol Navigator: AnyObject {
    
    #if canImport(UIKit)
    /// Pushes a given `UIViewController` onto the navigation stack.
    /// - Parameters:
    ///   - vc: The `UIViewController` to push.
    ///   - animated: Whether or not to animate the UI change.
    func push(_ vc: UIViewController, animated: Bool)
    #endif
    
    /// Pushes a given SwiftUI `View` onto the navigation stack.
    /// - Parameters:
    ///   - view: The `View` to push.
    ///   - animated: Whether or not to animate the UI change.
    func push<Content: View>(_ view: Content, animated: Bool)
    
    #if canImport(UIKit)
    /// Presents a given `UIViewController` in front of the current screen.
    /// - Parameters:
    ///   - vc: The `UIViewController` to present.
    ///   - animated: Whether or not to animate the UI change.
    func present(_ vc: UIViewController, animated: Bool)
    #endif
    
    /// Presents a given SwiftUI `View` in front of the current screen.
    /// - Parameters:
    ///   - view: The `View` to present.
    ///   - animated: Whether or not to animate the UI change.
    func present<Content: View>(_ view: Content, animated: Bool)
    
    /// Dismisses the current view which is being shown.
    /// - Parameter animated: Whether or not to animate the UI change.
    func dismiss(animated: Bool)
    
    /// Dismisses all of the views that this Navigator handles.
    /// - Parameter animated: Whether or not to animate the UI change.
    func dismissSelf(animated: Bool)
    
    /// Dismisses the current view which is being shown with the given completion handler.
    /// - Parameters:
    ///   - animated: Whether or not to animate the UI change.
    ///   - completion: Completion handler to be called after the dismissal.
    func dismissWithCompletion(animated: Bool, completion: @escaping () -> Void)
    
    /// Pops the top View on the current navigation stack.
    /// - Parameter animated: Whether or not to animate the UI change.
    func pop(animated: Bool)
}

#if canImport(UIKit)
/// Default methods for UINavigationControllers.
public extension Navigator where Self: UINavigationController {
    func push(_ vc: UIViewController, animated: Bool) {
        self.pushViewController(vc, animated: animated)
    }
    
    func push<Content: View>(_ view: Content, animated: Bool) {
        let viewController = UIHostingController(rootView: view)
        self.push(viewController, animated: animated)
    }
    
    func present(_ vc: UIViewController, animated: Bool) {
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: animated)
    }
    
    func present<Content: View>(_ view: Content, animated: Bool) {
        let viewController = UIHostingController(rootView: view)
        self.present(viewController, animated: animated)
    }
    
    func dismiss(animated: Bool) {
        self.dismiss(animated: animated)
    }
    
   func dismissSelf(animated: Bool) {
       self.presentationController?.presentingViewController.dismiss(animated: animated)
    }
    
    func dismissWithCompletion(animated: Bool, completion: @escaping () -> Void) {
        self.dismiss(animated: animated, completion: completion)
    }
    
    func pop(animated: Bool) {
        self.popViewController(animated: animated)
    }
}

extension UINavigationController: Navigator { /* no-op */ }
#endif
