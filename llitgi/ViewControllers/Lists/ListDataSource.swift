//
//  ListDataSource.swift
//  llitgi
//
//  Created by Xavi Moll on 25/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import UIKit

class ListDataSource: NSObject, TableViewCoreDataNotifier {
    
    //MARK:- Private properties
    private let userPreferences: UserManager
    private let themeManager: ThemeManager
    
    //MARK: Public properties
    weak var tableView: UITableView?
    var notifier: CoreDataNotifier?
    
    //MARK:- Public properties
    var typeOfList: TypeOfList
    var isSearch: Bool = false
    
    //MARK:- Lifecycle
    init(tableView: UITableView, userPreferences: UserManager, themeManager: ThemeManager, typeOfList: TypeOfList, notifier: CoreDataNotifier) {
        self.userPreferences = userPreferences
        self.themeManager = themeManager
        self.typeOfList = typeOfList
        super.init()
        self.tableView = tableView
        self.establishNotifier(notifier: notifier, isSearch: false)
    }
    
    //MARK:- Public methods
    func item(at indexPath: IndexPath) -> Item? {
        let item: Item? = self.notifier?.object(at: indexPath)
        return item
    }
    
    func numberOfItems() -> Int? {
        return self.notifier?.numberOfObjects(on: 0)
    }
    
    func establishNotifier(notifier: CoreDataNotifier, isSearch: Bool) {
        self.isSearch = isSearch
        self.notifier = notifier
        self.notifier?.delegate = self
        self.notifier?.startNotifying()
    }
}

//MARK:- UITableViewDataSource
extension ListDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfElements = self.notifier?.numberOfObjects(on: section) ?? 0
        if self.typeOfList == .myList && !isSearch {
            self.userPreferences.displayBadge(with: numberOfElements)
        }
        return numberOfElements
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = self.item(at: indexPath) else { return UITableViewCell() }
        let cell: ListCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.configure(with: item, theme: self.themeManager.theme)
        return cell
    }
}
