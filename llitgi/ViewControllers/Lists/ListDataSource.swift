//
//  ListDataSource.swift
//  llitgi
//
//  Created by Xavi Moll on 25/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import UIKit

class ListDataSource: NSObject {
    
    //MARK:- Private properties
    weak private var tableView: UITableView?
    private let userPreferences: PreferencesManager
    private let typeOfList: TypeOfList
    private var notifier: CoreDataNotifier?
    
    //MARK:- Lifecycle
    init(tableView: UITableView, userPreferences: PreferencesManager, typeOfList: TypeOfList, notifier: CoreDataNotifier) {
        self.userPreferences = userPreferences
        self.typeOfList = typeOfList
        super.init()
        self.tableView = tableView
        self.establishNotifier(notifier: notifier)
    }
    
    //MARK:- Public methods
    func item(at indexPath: IndexPath) -> Item? {
        let item: Item? = self.notifier?.object(at: indexPath)
        return item
    }
    
    func numberOfItems() -> Int? {
        return self.notifier?.numberOfObjects(on: 0)
    }
    
    func establishNotifier(notifier: CoreDataNotifier) {
        self.notifier = nil
        self.notifier = notifier.onBeginChanging({ [weak self] in
            self?.tableView?.beginUpdates()
        }).onObjectChanged({ [weak self] (change) in
            guard let strongSelf = self else { return }
            switch change {
            case .insert(let indexPath):
                strongSelf.tableView?.insertRows(at: [indexPath], with: .automatic)
            case .delete(let indexPath):
                strongSelf.tableView?.deleteRows(at: [indexPath], with: .automatic)
            case .update(let indexPath):
                strongSelf.tableView?.reloadRows(at: [indexPath], with: .automatic)
            case .move(let from, let to):
                strongSelf.tableView?.moveRow(at: from, to: to)
            }
        }).onFinishChanging({ [weak self] in
            self?.tableView?.endUpdates()
        }).startNotifying()
    }
}

//MARK:- UITableViewDataSource
extension ListDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfElements = self.notifier?.numberOfObjects(on: section) ?? 0
        if self.typeOfList == .myList {
            self.userPreferences.displayBadge(with: numberOfElements)
        }
        if numberOfElements == 0 {
            let title: String
            let subtitle: String
            switch self.typeOfList {
            case .myList:
                title = L10n.ListEmptyStates.myListTitle
                subtitle = L10n.ListEmptyStates.myListSubtitle
            case .favorites:
                title = L10n.ListEmptyStates.favoritesTitle
                subtitle = L10n.ListEmptyStates.favoritesSubtitle
            case .archive:
                title = L10n.ListEmptyStates.archiveTitle
                subtitle = L10n.ListEmptyStates.archiveSubtitle
            }
            tableView.establishEmptyState(title: title, subtitle: subtitle)
        } else {
            tableView.backgroundView = nil
        }
        return numberOfElements
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = self.item(at: indexPath) else { return UITableViewCell() }
        let cell: ListCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.configure(with: item)
        return cell
    }
}
