//
//  AppDelegate.swift
//  llitgi
//
//  Created by Xavi Moll on 24/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import UIKit
import CoreSpotlight

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let modelFactory: CoreDataFactory = CoreDataFactoryImplementation()
    var dataProvider: DataProvider!
    var viewControllerFactory: ViewControllerFactory!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        Logger.configureFabric()
        
        // Initialization of dependencies
        let pocketAPI = PocketAPIManager()
        self.dataProvider = DataProvider(pocketAPI: pocketAPI, modelFactory: modelFactory)
        let userPreferences = UserPreferencesManager()
        let dependencies = Dependencies(dataProvider: self.dataProvider, userPreferences: userPreferences)
        self.viewControllerFactory = ViewControllerFactory(dependencies: dependencies)
        
        let rootViewController = TabBarController(factory: self.viewControllerFactory)
        if let _ = LlitgiUserDefaults.shared.string(forKey: kAccesToken) {
            rootViewController.setupMainFlow()
        } else {
            rootViewController.setupAuthFlow()
        }
        
        // Establishing the window and rootViewController
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.makeKeyAndVisible()
        self.window?.tintColor = .black
        self.window?.rootViewController = rootViewController
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        // Handles the callback from the pocket app/website
        if url.scheme == "xmollv-llitgi" && url.host == "pocketAuth" {
            Logger.log("Auth finished")
            NotificationCenter.default.post(name: .OAuthFinished, object: nil)
        }
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if userActivity.activityType == CSSearchableItemActionType {
            if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
                guard let item = self.modelFactory.hasItem(identifiedBy: uniqueIdentifier) else { return false }
                guard let tabBarController = application.keyWindow?.rootViewController as? TabBarController else { return false }
                if let search = tabBarController.presentedViewController as? SearchViewController {
                    search.searchFromSpotlight(item: item)
                } else {
                    let search: SearchViewController = self.viewControllerFactory.instantiate()
                    tabBarController.present(search, animated: true, completion: nil)
                    search.searchFromSpotlight(item: item)
                }
            }
        }
        
        return true
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // The user is not logged in, there's no point in trying to sync anything
        guard let _ = LlitgiUserDefaults.shared.string(forKey: kAccesToken) else {
            completionHandler(.noData)
            return
        }
        
        self.dataProvider.syncLibrary { (result) in
            switch result {
            case .isSuccess(let items):
                // Because this is a sync operation, we just need to care if we get data or not
                items.isEmpty ? completionHandler(.noData) : completionHandler(.newData)
            case .isFailure(let error):
                Logger.log(error.localizedDescription, event: .error)
                completionHandler(.failed)
            }
        }
    }
}
