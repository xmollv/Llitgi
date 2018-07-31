//
//  AppCoordinator.swift
//  llitgi
//
//  Created by Xavi Moll on 31/07/2018.
//  Copyright © 2018 xmollv. All rights reserved.
//

import Foundation
import UIKit

protocol Coordinator {
    var firstViewController: UIViewController { get }
    func start()
}

final class AppCoordinator: Coordinator {
    
    //MARK: Private properties
    private let tabBarController: UITabBarController
    private let factory: ViewControllerFactory
    private let userManager: UserManager
    
    //MARK: Public properties
    var firstViewController: UIViewController {
        return self.tabBarController
    }
    
    //MARK: Lifecycle
    init(window: UIWindow, tabBarController: UITabBarController = UITabBarController(), factory: ViewControllerFactory, userManager: UserManager) {
        self.tabBarController = tabBarController
        self.factory = factory
        self.userManager = userManager
        
        // Configure the window
        window.tintColor = .black
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
    
    //MARK: Public methods
    func start() {
        let listViewController: ListViewController = self.factory.instantiateList(for: .myList)
        listViewController.title = L10n.Titles.myList
        listViewController.tabBarItem = UITabBarItem(title: L10n.Titles.myList, image: #imageLiteral(resourceName: "list"), tag: 1)
        
        let favoritesViewController: ListViewController = self.factory.instantiateList(for: .favorites)
        favoritesViewController.title = L10n.Titles.favorites
        favoritesViewController.tabBarItem = UITabBarItem(title: L10n.Titles.favorites, image: #imageLiteral(resourceName: "favorite"), tag: 2)
        
        let archiveViewController: ListViewController = self.factory.instantiateList(for: .archive)
        archiveViewController.title = L10n.Titles.archive
        archiveViewController.tabBarItem = UITabBarItem(title: L10n.Titles.archive, image: #imageLiteral(resourceName: "archive"), tag: 3)
        
        let tabs = [listViewController, favoritesViewController, archiveViewController].map { (viewController) -> UINavigationController in
            let navController = UINavigationController(rootViewController: viewController)
            navController.navigationBar.prefersLargeTitles = true
            navController.navigationBar.barTintColor = .white
            return navController
        }
        
        self.tabBarController.tabBar.barTintColor = .white
        self.tabBarController.setViewControllers(tabs, animated: false)
        
        if !self.userManager.isLoggedIn {
            self.showLogin(animated: false)
        }
    }
    
    //MARK: Private methods
    private func showLogin(animated: Bool = true) {
        let login = self.factory.instantiateAuth()
        login.modalPresentationStyle = .formSheet
        login.loginFinished = { [weak self] in
            self?.tabBarController.dismiss(animated: true, completion: nil)
        }
        self.tabBarController.present(login, animated: animated, completion: nil)
    }
}
