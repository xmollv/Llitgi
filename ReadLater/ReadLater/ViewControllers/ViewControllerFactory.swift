//
//  ViewControllerFactory.swift
//  ReadLater
//
//  Created by Xavi Moll on 24/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import Foundation
import UIKit

final class ViewControllerFactory {
    
    private let dataProvider: DataProvider
    
    init(dataProvider: DataProvider) {
        self.dataProvider = dataProvider
    }
    
    func instantiate<T: ViewController>() -> T {
        let viewController = T(factory: self, dataProvider: self.dataProvider)
        return viewController
    }
    
    func instantiateListViewController(type: TypeOfList) -> ListViewController {
        return ListViewController(factory: self, dataProvider: self.dataProvider, type: type)
    }
    
    func establishViewControllers(on tabBarController: UITabBarController) {
        //My List
        let listViewController: ListViewController = self.instantiateListViewController(type: .myList)
        let navControllerList = UINavigationController(rootViewController: listViewController)
        
        //Favorites
        let favoritesViewController: ListViewController = self.instantiateListViewController(type: .favorites)
        let navControllerFavorites = UINavigationController(rootViewController: favoritesViewController)
        
        //Archive
        let archiveViewController: ListViewController = self.instantiateListViewController(type: .archive)
        let navControllerArchive = UINavigationController(rootViewController: archiveViewController)
        
        tabBarController.setViewControllers([navControllerList, navControllerFavorites/*, navControllerArchive*/], animated: false)
        //In case that it was hidden by the auth, we make sure that it's not hidden
        tabBarController.tabBar.isHidden = false
        //Force all view controllers to be loaded
        tabBarController.viewControllers?.forEach { _ = ($0 as? UINavigationController)?.viewControllers.first?.view }
    }
    
    func establishAuthViewController(on tabBarController: UITabBarController) {
        let authViewController: AuthorizationViewController = self.instantiate()
        tabBarController.setViewControllers([authViewController], animated: false)
        tabBarController.tabBar.isHidden = true
    }
}
