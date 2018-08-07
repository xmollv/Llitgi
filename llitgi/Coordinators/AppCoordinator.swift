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

final class AppCoordinator: NSObject, Coordinator {
    
    //MARK: Private properties
    private let splitViewController: UISplitViewController
    private let tabBarController: UITabBarController
    private let factory: ViewControllerFactory
    private let userManager: UserManager
    
    //MARK: Public properties
    var firstViewController: UIViewController {
        return self.tabBarController
    }
    
    //MARK: Lifecycle
    init(window: UIWindow, tabBarController: UITabBarController = UITabBarController(), factory: ViewControllerFactory, userManager: UserManager) {
        self.splitViewController = UISplitViewController()
        self.tabBarController = tabBarController
        self.factory = factory
        self.userManager = userManager
        
        // Configure the window
        window.tintColor = .black
        window.rootViewController = self.splitViewController
        window.makeKeyAndVisible()
        
        super.init()
        self.tabBarController.delegate = self
    }
    
    //MARK: Public methods
    func start() {
        let listViewController: ListViewController = self.factory.instantiateList(for: .myList)
        listViewController.settingsButtonTapped = { [weak self] in
            self?.showSettings()
        }
        listViewController.safariToPresent = { [weak self] sfs in
            self?.splitViewController.showDetailViewController(sfs, sender: nil)
        }
        listViewController.title = L10n.Titles.myList
        listViewController.tabBarItem = UITabBarItem(title: L10n.Titles.myList, image: #imageLiteral(resourceName: "list"), tag: 1)
        
        let favoritesViewController: ListViewController = self.factory.instantiateList(for: .favorites)
        favoritesViewController.settingsButtonTapped = { [weak self] in
            self?.showSettings()
        }
        favoritesViewController.safariToPresent = { [weak self] sfs in
            self?.splitViewController.showDetailViewController(sfs, sender: nil)
        }
        favoritesViewController.title = L10n.Titles.favorites
        favoritesViewController.tabBarItem = UITabBarItem(title: L10n.Titles.favorites, image: #imageLiteral(resourceName: "favorite"), tag: 2)
        
        let archiveViewController: ListViewController = self.factory.instantiateList(for: .archive)
        archiveViewController.settingsButtonTapped = { [weak self] in
            self?.showSettings()
        }
        archiveViewController.safariToPresent = { [weak self] sfs in
            self?.splitViewController.showDetailViewController(sfs, sender: nil)
        }
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
        
        self.splitViewController.viewControllers = [self.tabBarController]
        self.splitViewController.preferredDisplayMode = .allVisible
        self.splitViewController.delegate = self
    }
    
    //MARK: Private methods
    private func showLogin(animated: Bool = true) {
        let login = self.factory.instantiateAuth()
        login.modalPresentationStyle = .formSheet
        login.loginFinished = { [weak self] in
            self?.splitViewController.dismiss(animated: true, completion: { [weak self] in
                self?.showFullSync()
            })
        }
        self.splitViewController.present(login, animated: animated, completion: nil)
    }
    
    private func showSettings() {
        let settingsViewController = self.factory.instantiateSettings()
        settingsViewController.logoutBlock = { [weak self] in
            self?.splitViewController.dismiss(animated: true, completion: { [weak self] in
                self?.showLogin()
            })
        }
        let navController = UINavigationController(rootViewController: settingsViewController)
        navController.navigationBar.barTintColor = .white
        navController.modalPresentationStyle = .formSheet
        self.splitViewController.present(navController, animated: true, completion: nil)
    }
    
    private func showFullSync() {
        let fullSync = self.factory.instantiateFullSync()
        fullSync.finishedSyncing = { [weak self] in
            self?.splitViewController.dismiss(animated: true, completion: nil)
        }
        fullSync.modalPresentationStyle = .overFullScreen
        fullSync.modalTransitionStyle = .crossDissolve
        self.splitViewController.present(fullSync, animated: true, completion: nil)
    }
}

extension AppCoordinator: UISplitViewControllerDelegate {
    func primaryViewController(forExpanding splitViewController: UISplitViewController) -> UIViewController? {
        return self.tabBarController
    }
    
    func primaryViewController(forCollapsing splitViewController: UISplitViewController) -> UIViewController? {
        return self.tabBarController
    }
}

extension AppCoordinator: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let newViewController = (viewController as? UINavigationController)?.topViewController else { return true }
        guard let currentViewController = (tabBarController.selectedViewController as? UINavigationController)?.topViewController else { return true }
        
        if let list = newViewController as? ListViewController {
            guard list.isEqual(currentViewController) else { return true }
            list.scrollToTop()
        }
        return true
    }
}
