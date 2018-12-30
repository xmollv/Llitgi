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
    
    //MARK: Lifecycle
    init(dataProvider: DataProvider, userManager: UserManager, themeManager: ThemeManager) {
        self.dataProvider = dataProvider
        self.userManager = userManager
        self.themeManager = themeManager
    }
    
    //MARK: Public methods
    func instantiateAuth() -> AuthorizationViewController {
        return AuthorizationViewController(dataProvider: self.dataProvider, themeManager: self.themeManager)
    }
    
    func instantiateLists() -> [ItemsViewController] {
        let listViewController: ItemsViewController = self.instantiateList(for: .myList)
        listViewController.title = L10n.Titles.myList
        listViewController.tabBarItem = UITabBarItem(title: L10n.Titles.myList, image: #imageLiteral(resourceName: "list"), tag: 1)
        
        let favoritesViewController: ItemsViewController = self.instantiateList(for: .favorites)
        favoritesViewController.title = L10n.Titles.favorites
        favoritesViewController.tabBarItem = UITabBarItem(title: L10n.Titles.favorites, image: #imageLiteral(resourceName: "favorite"), tag: 2)
        
        let archiveViewController: ItemsViewController = self.instantiateList(for: .archive)
        archiveViewController.title = L10n.Titles.archive
        archiveViewController.tabBarItem = UITabBarItem(title: L10n.Titles.archive, image: #imageLiteral(resourceName: "archive"), tag: 3)
        
        return [listViewController, favoritesViewController, archiveViewController]
    }
    
    private func instantiateList(for type: TypeOfList) -> ItemsViewController {
        return ItemsViewController(notifier: self.dataProvider.notifier(for: type), dataProvider: self.dataProvider, userManager: self.userManager, themeManager: self.themeManager, type: type)
    }
    
    func instantiateList(for tag: Tag) -> TaggedItemsViewController {
        return TaggedItemsViewController(notifier: self.dataProvider.notifier(for: tag), dataProvider: self.dataProvider, userManager: self.userManager, themeManager: self.themeManager, tag: tag)
    }
    
    func instantiateSettings() -> SettingsViewController {
        return SettingsViewController(userManager: self.userManager, dataProvider: self.dataProvider, themeManager: self.themeManager)
    }
    
    func instantiateFullSync() -> FullSyncViewController {
        return FullSyncViewController(dataProvider: self.dataProvider)
    }
    
    func instantiateManageTagsViewController(item: Item, completed: @escaping () -> Void) -> ManageTagsViewController {
        return ManageTagsViewController(item: item, dataProvider: self.dataProvider, themeManager: self.themeManager, completed: completed)
    }
    
    func instantiateTagsList() -> TagsViewController {
        let tags = TagsViewController(notifier: self.dataProvider.tagsNotifier, dataProvider: self.dataProvider, userManager: self.userManager, themeManager: self.themeManager)
        tags.title = L10n.Titles.tags
        tags.tabBarItem = UITabBarItem(title: L10n.Titles.tags, image: #imageLiteral(resourceName: "tag"), tag: 4)
        return tags
    }
}
