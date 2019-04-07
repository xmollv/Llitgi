//
//  AppDelegate.swift
//  llitgi
//
//  Created by Xavi Moll on 24/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    private let window = UIWindow(frame: UIScreen.main.bounds)
    private let dataProvider = DataProvider(pocketAPI: PocketAPIManager(), modelFactory: CoreDataFactoryImplementation())
    private let userManager: UserManager = UserPreferencesManager()
    private var appCoordinator: Coordinator!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        
        let theme: Theme = .dark
        
        let viewControllerFactory = ViewControllerFactory(dataProvider: self.dataProvider,
                                                          userManager: self.userManager,
                                                          theme: theme)
        self.appCoordinator = AppCoordinator(window: self.window,
                                             factory: viewControllerFactory,
                                             userManager: self.userManager,
                                             dataProvider: self.dataProvider,
                                             theme: theme)
        self.appCoordinator.start()
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // Handles the callback from the pocket app/website
        if url.scheme == "xmollv-llitgi" && url.host == "pocketAuth" {
            NotificationCenter.default.post(name: .OAuthFinished, object: nil)
        }
        return true
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // The user is not logged in, there's no point in trying to sync anything
        guard self.userManager.isLoggedIn else {
            completionHandler(.noData)
            return
        }
        
        self.dataProvider.syncLibrary { (result) in
            switch result {
            case .success(let items):
                // Because this is a sync operation, we just need to care if we get data or not
                items.isEmpty ? completionHandler(.noData) : completionHandler(.newData)
            case .failure(let error):
                Logger.log(error.localizedDescription, event: .error)
                completionHandler(.failed)
            }
        }
    }
}
