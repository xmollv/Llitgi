//
//  TabBarController.swift
//  llitgi
//
//  Created by Xavi Moll on 16/02/2018.
//  Copyright © 2018 xmollv. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    let factory: ViewControllerFactory
    
    init(factory: ViewControllerFactory) {
        self.factory = factory
        super.init(nibName: nil, bundle: nil)
        self.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setupAuthFlow() {
        let authViewController: AuthorizationViewController = self.factory.instantiate()
        self.setViewControllers([authViewController], animated: false)
        self.tabBar.isHidden = true
    }

    func setupMainFlow() {
        let listViewController: ListViewController = self.factory.instantiateListViewController(type: .myList)
        listViewController.tabBarItem = UITabBarItem(title: NSLocalizedString("My List", comment: ""), image: #imageLiteral(resourceName: "list"), tag: 1)
        
        let favoritesViewController: ListViewController = self.factory.instantiateListViewController(type: .favorites)
        favoritesViewController.tabBarItem = UITabBarItem(title: NSLocalizedString("Favorites", comment: ""), image: #imageLiteral(resourceName: "favorite"), tag: 2)
        
        let archiveViewController: ListViewController = self.factory.instantiateListViewController(type: .archive)
        archiveViewController.tabBarItem = UITabBarItem(title: NSLocalizedString("Archive", comment: ""), image: #imageLiteral(resourceName: "archive"), tag: 3)
        
        let searchViewController: SearchViewController = self.factory.instantiate()
        searchViewController.tabBarItem = UITabBarItem(title: NSLocalizedString("Search", comment: ""), image: #imageLiteral(resourceName: "search"), tag: 4)
        
        let settingsViewController: SettingsViewController = self.factory.instantiate()
        settingsViewController.tabBarItem = UITabBarItem(title: NSLocalizedString("Settings", comment: ""), image: #imageLiteral(resourceName: "settings"), tag: 5)
        
        let tabs = [listViewController, favoritesViewController, archiveViewController, searchViewController, settingsViewController].map({ UINavigationController(rootViewController: $0) })
        
        self.setViewControllers(tabs, animated: false)
        self.tabBar.isHidden = false
    }
}

extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tag = viewController.tabBarItem.tag
        guard tag > tabBarController.tabBar.subviews.count || tag < tabBarController.tabBar.subviews.count else { return }
        let viewToBetransformed = tabBarController.tabBar.subviews[tag]
        viewToBetransformed.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 10, animations: {
            viewToBetransformed.transform = .identity
        }, completion: nil)
    }
    
}
