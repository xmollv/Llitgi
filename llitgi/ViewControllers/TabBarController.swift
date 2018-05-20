//
//  TabBarController.swift
//  llitgi
//
//  Created by Xavi Moll on 16/02/2018.
//  Copyright © 2018 xmollv. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    //MARK: Private properties
    private let factory: ViewControllerFactory
    
    //MARK: Lifecycle
    init(factory: ViewControllerFactory) {
        self.factory = factory
        super.init(nibName: nil, bundle: nil)
        self.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Public methods
    func setupAuthFlow() {
        let authViewController = self.factory.instantiateAuth()
        self.setViewControllers([authViewController], animated: false)
        self.tabBar.isHidden = true
    }

    func setupMainFlow() {
        let listViewController: ListViewController = self.factory.instantiateList(for: .myList)
        listViewController.title = L10n.Titles.myList
        listViewController.tabBarItem = UITabBarItem(title: L10n.Titles.myList, image: #imageLiteral(resourceName: "list"), tag: 1)
        
        let favoritesViewController: ListViewController = self.factory.instantiateList(for: .favorites)
        favoritesViewController.title = L10n.Titles.favorites
        favoritesViewController.tabBarItem = UITabBarItem(title: L10n.Titles.favorites, image: #imageLiteral(resourceName: "favorite"), tag: 2)
        
        let archiveViewController: ListViewController = self.factory.instantiateList(for: .archive)
        archiveViewController.title = L10n.Titles.archive
        archiveViewController.tabBarItem = UITabBarItem(title: L10n.Titles.archive, image: #imageLiteral(resourceName: "archive"), tag: 3)
        
        let tabs = [listViewController, favoritesViewController, archiveViewController].map({ UINavigationController(rootViewController: $0) })
        tabs.forEach {
            $0.navigationBar.prefersLargeTitles = true
            $0.navigationBar.barTintColor = .white
            $0.navigationBar.isTranslucent = false
            $0.navigationBar.isOpaque = true
        }
        
        self.tabBar.isHidden = false
        self.tabBar.barTintColor = .white
        self.setViewControllers(tabs, animated: false)
    }
}

extension TabBarController: UITabBarControllerDelegate {
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
