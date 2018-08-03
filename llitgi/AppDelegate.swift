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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(1800)
        
        let flowManager = FlowManager(window: window, dataProvider: dataProvider, userManager: userManager)
        
        if self.userManager.isLoggedIn {
            flowManager.setupMainFlow()
        } else {
            flowManager.setupAuthFlow()
        }
        
        // Establishing the window and rootViewController
        self.window.makeKeyAndVisible()
        self.window.tintColor = .black
        
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
        guard !self.userManager.isLoggedIn else {
            completionHandler(.noData)
            return
        }
        
        self.dataProvider.syncLibrary { [weak self] (result) in
            guard let strongSelf = self else { return }
            switch result {
            case .isSuccess(let items):
                // Because this is a sync operation, we just need to care if we get data or not
                strongSelf.userManager.displayBadge(with: strongSelf.dataProvider.numberOfItems(on: .myList))
                items.isEmpty ? completionHandler(.noData) : completionHandler(.newData)
            case .isFailure(let error):
                Logger.log(error.localizedDescription, event: .error)
                completionHandler(.failed)
            }
        }
    }
}
