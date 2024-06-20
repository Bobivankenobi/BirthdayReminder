import UIKit
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        // Initialize the window
        window = UIWindow(windowScene: windowScene)
        
        // Create a reference to the main storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Create the initial view controller from the storyboard
        let initialViewController = storyboard.instantiateInitialViewController() as! UITabBarController
        
        
        // Set up the context for the initial view controller
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        print("Context in SceneDelegate: \(context)")
        
        // Iterate over the tab bar view controllers
        if let viewControllers = initialViewController.viewControllers {
            for viewController in viewControllers {
                if let navController = viewController as? UINavigationController {
                    if let tagVC = navController.viewControllers.first as? TagVC {
                        tagVC.managedContext = context
                        print("Managed context is set in TagVC: \(context)")
                    } else if let calendarVC = navController.viewControllers.first as? CalendarVC {
                        calendarVC.managedContext = context
                        print("Managed context is set in CalendarVC: \(context)")
                    }
                } else if let calendarVC = viewController as? CalendarVC {
                    calendarVC.managedContext = context
                    print("Managed context is set in CalendarVC: \(context)")
                }
            }
        }
        
        // Set the root view controller and make the window visible
        window?.rootViewController = initialViewController
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Undo changes made when entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}
