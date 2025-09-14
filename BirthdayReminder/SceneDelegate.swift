import UIKit
import CoreData
import GoogleSignIn
import Combine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var authManager = AuthenticationManager.shared
    private var cancellables = Set<AnyCancellable>()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)
        
        // Set up authentication state observer
        setupAuthenticationObserver()
        
        // Show initial screen based on authentication state
        showInitialScreen()
        
        window?.makeKeyAndVisible()
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        GIDSignIn.sharedInstance.handle(url)
    }
    
    private func setupAuthenticationObserver() {
        // Listen to AuthenticationManager changes
        authManager.$isAuthenticated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAuthenticated in
                if isAuthenticated {
                    self?.showMainApp()
                } else {
                    self?.showAuthenticationScreen()
                }
            }
            .store(in: &cancellables)
    }
    
    private func showInitialScreen() {
        if authManager.isAuthenticated {
            showMainApp()
        } else {
            showAuthenticationScreen()
        }
    }
    
    private func showAuthenticationScreen() {
        let authVC = AuthenticationViewController()
        window?.rootViewController = authVC
    }
    
    private func showMainApp() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateInitialViewController() as! UITabBarController
        
        // Set up the context for the initial view controller
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        // Iterate over the tab bar view controllers
        if let viewControllers = initialViewController.viewControllers {
            for viewController in viewControllers {
                if let navController = viewController as? UINavigationController {
                    if let tagVC = navController.viewControllers.first as? TagVC {
                        tagVC.managedContext = context
                        
                        // Add logout button to TagVC
                        let logoutButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutTapped))
                        tagVC.navigationItem.leftBarButtonItem = logoutButton
                        
                    } else if let calendarVC = navController.viewControllers.first as? CalendarVC {
                        calendarVC.managedContext = context
                    }
                } else if let calendarVC = viewController as? CalendarVC {
                    calendarVC.managedContext = context
                }
            }
        }
        
        window?.rootViewController = initialViewController
    }
    
    @objc private func logoutTapped() {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
            self?.authManager.signOut()
        })
        
        window?.rootViewController?.present(alert, animated: true)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}
