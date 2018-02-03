//
//  AppDelegate.swift
//  litgi
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
        let modelFactory = CoreDataFactoryImplementation()
        let dataProvider = DataProvider(pocketAPI: pocketAPI, modelFactory: modelFactory)
        let syncManager = SyncManager(dataProvider: dataProvider)
        let userPreferences = UserPreferencesManager()
        let dependencies = Dependencies(dataProvider: dataProvider, syncManager: syncManager, userPreferences: userPreferences)
        let viewControllerFactory = ViewControllerFactory(dependencies: dependencies)
        
        // Establishing the window and rootViewController
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.makeKeyAndVisible()
        self.window?.tintColor = .black
        self.window?.rootViewController = self.rootViewController(factory: viewControllerFactory)
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        // Handles the callback from the pocket app/website
        if url.scheme == "xmollv-litgi" && url.host == "pocketAuth" {
            Logger.log("Auth finished")
            NotificationCenter.default.post(name: .OAuthFinished, object: nil)
        }
        return true
    }
    
    private func rootViewController(factory: ViewControllerFactory) -> UITabBarController {
        let tabBarController = UITabBarController()
        if let _ = LitgiUserDefaults.shared.string(forKey: kAccesToken) {
            factory.establishViewControllers(on: tabBarController)
        } else {
            factory.establishAuthViewController(on: tabBarController)
        }
        return tabBarController
    }

}

