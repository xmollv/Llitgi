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
        let listViewController: ListViewController = self.factory.instantiate(for: .myList)
        listViewController.tabBarItem = UITabBarItem(title: NSLocalizedString("my_list", comment: ""), image: #imageLiteral(resourceName: "list"), tag: 1)
        
        let favoritesViewController: ListViewController = self.factory.instantiate(for: .favorites)
        favoritesViewController.tabBarItem = UITabBarItem(title: NSLocalizedString("favorites", comment: ""), image: #imageLiteral(resourceName: "favorite"), tag: 2)
        
        let archiveViewController: ListViewController = self.factory.instantiate(for: .archive)
        archiveViewController.tabBarItem = UITabBarItem(title: NSLocalizedString("archive", comment: ""), image: #imageLiteral(resourceName: "archive"), tag: 3)
        
        let settingsViewController: SettingsViewController = self.factory.instantiate()
        settingsViewController.tabBarItem = UITabBarItem(title: NSLocalizedString("settings", comment: ""), image: #imageLiteral(resourceName: "settings"), tag: 4)
        
        let tabs = [listViewController, favoritesViewController, archiveViewController, settingsViewController].map({ UINavigationController(rootViewController: $0) })
        
        self.setViewControllers(tabs, animated: false)
        self.tabBar.isHidden = false
    }
}

extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        guard let newViewController = (viewController as? UINavigationController)?.topViewController else { return true}
        guard let currentViewController = (tabBarController.selectedViewController as? UINavigationController)?.topViewController else { return true }
        
        if let list = newViewController as? ListViewController {
            guard list.isEqual(currentViewController) else { return true }
            list.scrollToTop()
        }
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tag = viewController.tabBarItem.tag
        guard tag > tabBarController.tabBar.subviews.count || tag < tabBarController.tabBar.subviews.count else { return }
        let viewToBetransformed = tabBarController.tabBar.subviews[tag]
        viewToBetransformed.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, animations: {
            viewToBetransformed.transform = .identity
        }, completion: nil)
    }
    
}
