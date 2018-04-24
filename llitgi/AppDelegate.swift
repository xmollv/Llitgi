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
    private var dataProvider: DataProvider!
    private let userPreferences = UserPreferencesManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(1800)
        
        let pocketAPI = PocketAPIManager()
        let modelFactory = CoreDataFactoryImplementation()
        self.dataProvider = DataProvider(pocketAPI: pocketAPI, modelFactory: modelFactory)
        let dependencies = Dependencies(dataProvider: self.dataProvider, userPreferences: self.userPreferences)
        let viewControllerFactory = ViewControllerFactory(dependencies: dependencies)
        
        let rootViewController = TabBarController(factory: viewControllerFactory)
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
            NotificationCenter.default.post(name: .OAuthFinished, object: nil)
        }
        return true
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // The user is not logged in, there's no point in trying to sync anything
        guard let _ = LlitgiUserDefaults.shared.string(forKey: kAccesToken) else {
            completionHandler(.noData)
            return
        }
        
        self.dataProvider.syncLibrary { [weak self] (result) in
            guard let strongSelf = self else { return }
            switch result {
            case .isSuccess(let items):
                // Because this is a sync operation, we just need to care if we get data or not
                strongSelf.userPreferences.displayBadge(with: strongSelf.dataProvider.numberOfItems(on: .myList))
                items.isEmpty ? completionHandler(.noData) : completionHandler(.newData)
            case .isFailure(let error):
                Logger.log(error.localizedDescription, event: .error)
                completionHandler(.failed)
            }
        }
    }
}
