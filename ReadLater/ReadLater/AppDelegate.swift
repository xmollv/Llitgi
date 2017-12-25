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
        let rootViewController = self.getRootViewController(factory: viewControllerFactory)
        window?.rootViewController = rootViewController
        
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
    
    private func getRootViewController(factory: ViewControllerFactory) -> UIViewController {
        let authViewController: AuthorizationViewController = factory.instantiate()
        return authViewController
    }

}

