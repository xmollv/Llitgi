//
//  AppCoordinator.swift
//  llitgi
//
//  Created by Xavi Moll on 31/07/2018.
//  Copyright © 2018 xmollv. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

protocol Coordinator {
    func start()
}

final class AppCoordinator: NSObject, Coordinator {
    
    //MARK: Private properties
    private let splitViewController: UISplitViewController
    private let tabBarController: UITabBarController
    private var navController: UINavigationController {
        let navController = UINavigationController()
        navController.setNavigationBarHidden(true, animated: false)
        navController.view.backgroundColor = .white
        if let sfs = self.presentedSafari {
            navController.setViewControllers([sfs], animated: true)
        }
        return navController
    }
    weak private var presentedSafari: SFSafariViewController?
    private let factory: ViewControllerFactory
    private let userManager: UserManager
    
    private lazy var presentSafariClosure: ((SFSafariViewController) -> Void)? = { [weak self] sfs in
        guard let strongSelf = self else { return }
        strongSelf.presentedSafari = sfs
        strongSelf.splitViewController.showDetailViewController(sfs, sender: nil)
    }
    
    //MARK: Lifecycle
    init(window: UIWindow, tabBarController: UITabBarController = UITabBarController(), factory: ViewControllerFactory, userManager: UserManager) {
        self.splitViewController = UISplitViewController()
        self.tabBarController = tabBarController
        self.factory = factory
        self.userManager = userManager
        
        super.init()
        
        let listViewController: ListViewController = self.factory.instantiateList(for: .myList)
        listViewController.settingsButtonTapped = { [weak self] in
            self?.showSettings()
        }
        listViewController.safariToPresent = self.presentSafariClosure
        listViewController.title = L10n.Titles.myList
        listViewController.tabBarItem = UITabBarItem(title: L10n.Titles.myList, image: #imageLiteral(resourceName: "list"), tag: 1)
        
        let favoritesViewController: ListViewController = self.factory.instantiateList(for: .favorites)
        favoritesViewController.settingsButtonTapped = { [weak self] in
            self?.showSettings()
        }
        favoritesViewController.safariToPresent = self.presentSafariClosure
        favoritesViewController.title = L10n.Titles.favorites
        favoritesViewController.tabBarItem = UITabBarItem(title: L10n.Titles.favorites, image: #imageLiteral(resourceName: "favorite"), tag: 2)
        
        let archiveViewController: ListViewController = self.factory.instantiateList(for: .archive)
        archiveViewController.settingsButtonTapped = { [weak self] in
            self?.showSettings()
        }
        archiveViewController.safariToPresent = self.presentSafariClosure
        archiveViewController.title = L10n.Titles.archive
        archiveViewController.tabBarItem = UITabBarItem(title: L10n.Titles.archive, image: #imageLiteral(resourceName: "archive"), tag: 3)
        
        let tabs = [listViewController, favoritesViewController, archiveViewController].map { (viewController) -> UINavigationController in
            let navController = UINavigationController(rootViewController: viewController)
            navController.navigationBar.prefersLargeTitles = true
            navController.navigationBar.barTintColor = .white
            return navController
        }
        
        self.tabBarController.tabBar.barTintColor = .white
        self.tabBarController.delegate = self
        self.tabBarController.setViewControllers(tabs, animated: false)
        
        self.splitViewController.viewControllers = [self.tabBarController, self.navController]
        self.splitViewController.preferredDisplayMode = .allVisible
        self.splitViewController.delegate = self
        
        // Configure the window
        window.makeKeyAndVisible()
        window.tintColor = .black
        window.rootViewController = self.splitViewController
    }
    
    //MARK: Public methods
    func start() {
        if !self.userManager.isLoggedIn {
            self.showLogin(animated: false)
        }
    }
    
    //MARK: Private methods
    private func showLogin(animated: Bool = true) {
        let login = self.factory.instantiateAuth()
        login.modalPresentationStyle = .formSheet
        
        login.safariToPresent = { [weak login] sfs in
            login?.present(sfs, animated: true, completion: nil)
        }
        
        login.loginFinished = { [weak self] in
            self?.splitViewController.dismiss(animated: true, completion: { [weak self] in
                self?.showFullSync()
            })
        }
        
        self.splitViewController.present(login, animated: animated, completion: nil)
    }
    
    private func showSettings() {
        let settingsViewController = self.factory.instantiateSettings()
        
        settingsViewController.doneBlock = { [weak self] in
            self?.splitViewController.dismiss(animated: true, completion: nil)
        }
        
        settingsViewController.logoutBlock = { [weak self] in
            guard let strongSelf = self else { return }
            if strongSelf.splitViewController.traitCollection.horizontalSizeClass == .regular {
                strongSelf.splitViewController.showDetailViewController(strongSelf.navController, sender: nil)
            }
            
            strongSelf.splitViewController.dismiss(animated: true, completion: { [weak self] in
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
    func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        self.tabBarController.dismiss(animated: false, completion: nil)
        return self.navController
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
