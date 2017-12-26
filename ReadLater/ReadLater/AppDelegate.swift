//
//  AppDelegate.swift
//  ReadLater
//
//  Created by Xavi Moll on 24/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Initialization of dependencies
        let pocketAPI = PocketAPIManager()
        let dataProvider = DataProvider(pocketAPI: pocketAPI)
        let viewControllerFactory = ViewControllerFactory(dataProvider: dataProvider)
        
        // Establishing the window and rootViewController
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.makeKeyAndVisible()
        self.window?.tintColor = .black
        self.window?.rootViewController = self.rootViewController(factory: viewControllerFactory)
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        // Handles the callback from the pocket app/website
        if url.scheme == "xmollv-readlater" && url.host == "pocketAuth" {
            Logger.log("Auth finished")
            NotificationCenter.default.post(name: .OAuthFinished, object: nil)
        }
        return true
    }
    
    private func rootViewController(factory: ViewControllerFactory) -> UITabBarController {
        let tabBarController = UITabBarController()
        if let _ = UserDefaults.standard.string(forKey: kAccesToken) {
            let favoritesViewController: FavoritesViewController = factory.instantiate()
            let navControllerFavorites = UINavigationController(rootViewController: favoritesViewController)
            
            let listViewController: MyListViewController = factory.instantiate()
            let navControllerList = UINavigationController(rootViewController: listViewController)
            
            let archiveViewController: ArchiveViewController = factory.instantiate()
            let navControllerArchive = UINavigationController(rootViewController: archiveViewController)
            
            tabBarController.setViewControllers([navControllerFavorites, navControllerList, navControllerArchive], animated: false)
            tabBarController.selectedIndex = 1
            tabBarController.viewControllers?.forEach { _ = ($0 as? UINavigationController)?.viewControllers.first?.view }
        } else {
            let authViewController: AuthorizationViewController = factory.instantiate()
            tabBarController.setViewControllers([authViewController], animated: false)
            tabBarController.tabBar.isHidden = true
        }
        return tabBarController
    }

}

