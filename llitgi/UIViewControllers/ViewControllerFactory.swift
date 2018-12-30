//
//  ViewControllerFactory.swift
//  llitgi
//
//  Created by Xavi Moll on 24/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import Foundation
import UIKit

final class ViewControllerFactory {
    
    //MARK: Private properties
    private let dataProvider: DataProvider
    private let userManager: UserManager
    private let themeManager: ThemeManager
    
    //MARK: Public properties
    var listsViewControllers: [ItemsViewController] {
        let listViewController = ItemsViewController(notifier: self.dataProvider.notifier(for: .myList),
                                                     dataProvider: self.dataProvider,
                                                     userManager: self.userManager,
                                                     themeManager: self.themeManager,
                                                     type: .myList)
        listViewController.title = L10n.Titles.myList
        listViewController.tabBarItem = UITabBarItem(title: L10n.Titles.myList, image: #imageLiteral(resourceName: "list"), tag: 1)
        
        let favoritesViewController = ItemsViewController(notifier: self.dataProvider.notifier(for: .favorites),
                                                          dataProvider: self.dataProvider,
                                                          userManager: self.userManager,
                                                          themeManager: self.themeManager,
                                                          type: .favorites)
        favoritesViewController.title = L10n.Titles.favorites
        favoritesViewController.tabBarItem = UITabBarItem(title: L10n.Titles.favorites, image: #imageLiteral(resourceName: "favorite"), tag: 2)
        
        let archiveViewController = ItemsViewController(notifier: self.dataProvider.notifier(for: .archive),
                                                        dataProvider: self.dataProvider,
                                                        userManager: self.userManager,
                                                        themeManager: self.themeManager,
                                                        type: .archive)
        archiveViewController.title = L10n.Titles.archive
        archiveViewController.tabBarItem = UITabBarItem(title: L10n.Titles.archive, image: #imageLiteral(resourceName: "archive"), tag: 3)
        
        return [listViewController, favoritesViewController, archiveViewController]
    }
    
    var tagsViewController: TagsViewController {
        let tags = TagsViewController(notifier: self.dataProvider.tagsNotifier,
                                      dataProvider: self.dataProvider,
                                      themeManager: self.themeManager)
        tags.title = L10n.Titles.tags
        tags.tabBarItem = UITabBarItem(title: L10n.Titles.tags, image: #imageLiteral(resourceName: "tag"), tag: 4)
        return tags
    }
    
    var loginViewController: LoginViewController {
        return LoginViewController(dataProvider: self.dataProvider,
                                   themeManager: self.themeManager)
    }
    
    var fullSyncViewController: FullSyncViewController {
        return FullSyncViewController(dataProvider: self.dataProvider)
    }
    
    var settingsViewController: SettingsViewController {
        return SettingsViewController(userManager: self.userManager,
                                      dataProvider: self.dataProvider,
                                      themeManager: self.themeManager)
    }
    
    //MARK: Lifecycle
    init(dataProvider: DataProvider, userManager: UserManager, themeManager: ThemeManager) {
        self.dataProvider = dataProvider
        self.userManager = userManager
        self.themeManager = themeManager
    }
    
    //MARK: Public methods
    func itemsViewController(for tag: Tag) -> TaggedItemsViewController {
        return TaggedItemsViewController(notifier: self.dataProvider.notifier(for: tag),
                                         dataProvider: self.dataProvider,
                                         userManager: self.userManager,
                                         themeManager: self.themeManager,
                                         tag: tag)
    }
    
    func manageTagsViewController(for item: Item, completed: @escaping () -> Void) -> ManageTagsViewController {
        return ManageTagsViewController(item: item,
                                        dataProvider: self.dataProvider,
                                        themeManager: self.themeManager,
                                        completed: completed)
    }
}
