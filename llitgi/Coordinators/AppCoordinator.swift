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
    private let factory: ViewControllerFactory
    private let userManager: UserManager
    private let dataProvider: DataProvider
    private let splitViewController: UISplitViewController
    private let tabBarController: UITabBarController
    private let themeManager: ThemeManager
    weak private var presentedSafari: SFSafariViewController?
    
    private lazy var presentSafariClosure: ((SFSafariViewController) -> Void)? = { [weak self] sfs in
        guard let strongSelf = self else { return }
        strongSelf.presentedSafari = sfs
        strongSelf.presentedSafari?.delegate = strongSelf
        strongSelf.splitViewController.showDetailViewController(sfs, sender: nil)
    }
    
    //MARK: Lifecycle
    init(window: UIWindow, factory: ViewControllerFactory, userManager: UserManager, dataProvider: DataProvider, themeManager: ThemeManager) {
        self.factory = factory
        self.userManager = userManager
        self.dataProvider = dataProvider
        self.themeManager = themeManager
        self.splitViewController = UISplitViewController()
        self.tabBarController = UITabBarController()

        super.init()
        
        let tabs = self.factory.instantiateLists().map { (vc) -> UINavigationController in
            vc.safariToPresent = self.presentSafariClosure
            vc.settingsButtonTapped = { [weak self] in self?.showSettings() }
            let navController = UINavigationController(rootViewController: vc)
            navController.navigationBar.prefersLargeTitles = true
            navController.navigationBar.barStyle = self.themeManager.theme.barStyle
            return navController
        }

        self.tabBarController.tabBar.barStyle = self.themeManager.theme.barStyle
        self.tabBarController.delegate = self
        self.tabBarController.setViewControllers(tabs, animated: false)
        
        self.splitViewController.viewControllers = [self.tabBarController]
        self.splitViewController.preferredDisplayMode = .allVisible
        self.splitViewController.delegate = self
        self.splitViewController.view.backgroundColor = self.themeManager.theme.backgroundColor
        
        // Configure the window
        window.makeKeyAndVisible()
        window.tintColor = self.themeManager.theme.tintColor
        UIApplication.shared.statusBarStyle = self.themeManager.theme.statusBarStyle
        self.themeManager.addObserver(self) { [weak self, weak window] theme in
            window?.tintColor = theme.tintColor
            self?.tabBarController.viewControllers?.forEach {
                guard let navBar = ($0 as? UINavigationController)?.navigationBar else { return }
                navBar.barStyle = theme.barStyle
            }
            self?.tabBarController.tabBar.barStyle = theme.barStyle
            self?.splitViewController.view.backgroundColor = theme.backgroundColor
            UIApplication.shared.statusBarStyle = theme.statusBarStyle
        }
        window.rootViewController = self.splitViewController
    }
    
    deinit {
        self.themeManager.removeObserver(self)
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
            strongSelf.presentedSafari = nil
            if strongSelf.splitViewController.traitCollection.horizontalSizeClass == .regular {
                strongSelf.splitViewController.viewControllers = [strongSelf.tabBarController]
            }
            
            strongSelf.splitViewController.dismiss(animated: true, completion: { [weak self] in
                self?.showLogin()
                self?.dataProvider.clearLocalStorage()
            })
        }
        let navController = UINavigationController(rootViewController: settingsViewController)
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
        if splitViewController.presentedViewController is SFSafariViewController {
            splitViewController.dismiss(animated: false, completion: nil)
        }
        return self.presentedSafari
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

extension AppCoordinator: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        guard self.splitViewController.traitCollection.horizontalSizeClass == .regular else { return }
        self.presentedSafari = nil
        self.splitViewController.viewControllers = [self.tabBarController]
    }
}
