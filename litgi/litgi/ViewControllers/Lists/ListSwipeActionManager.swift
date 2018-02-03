//
//  ListSwipeActionBuilder.swift
//  litgi
//
//  Created by Xavi Moll on 27/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import Foundation
import UIKit

class ListSwipeActionManager {
    
    private let type: TypeOfList
    private let dataSource: ListDataSource?
    private let dataProvider: DataProvider
    
    init(list: TypeOfList, dataSource: ListDataSource?, dataProvider: DataProvider) {
        self.type = list
        self.dataSource = dataSource
        self.dataProvider = dataProvider
    }
    
    func buildLeadingActions(at indexPath: IndexPath, from tableView: UITableView) -> [UIContextualAction] {
        guard var item = self.dataSource?.item(at: indexPath) else { return [] }
        switch self.type {
        case .myList:
            let favoriteAction = UIContextualAction(style: .normal, title: nil) { [weak self] (action, view, success) in
                guard let strongSelf = self else { return }
                
                let modification: ItemModification
                if item.isFavorite {
                    modification = ItemModification(action: .unfavorite, id: item.id)
                } else {
                    modification = ItemModification(action: .favorite, id: item.id)
                }
                
                strongSelf.dataProvider.performInMemoryWithoutResultType(endpoint: .modify(modification))
                item.isFavorite = !item.isFavorite
                success(true)
            }
            favoriteAction.title = item.isFavorite ? NSLocalizedString("Unfavorite", comment: "") : NSLocalizedString("Favorite", comment: "")
            return [favoriteAction]
        case .favorites:
            let favoriteAction = UIContextualAction(style: .normal, title: nil) { [weak self] (action, view, success) in
                guard let strongSelf = self else { return }
                
                let modification = ItemModification(action: .unfavorite, id: item.id)
                strongSelf.dataProvider.performInMemoryWithoutResultType(endpoint: .modify(modification))
                item.isFavorite = !item.isFavorite
                success(true)
            }
            favoriteAction.title = item.isFavorite ? NSLocalizedString("Unfavorite", comment: "") : NSLocalizedString("Favorite", comment: "")
            return [favoriteAction]
        case .archive:
            let favoriteAction = UIContextualAction(style: .normal, title: nil) { [weak self] (action, view, success) in
                guard let strongSelf = self else { return }
                
                let modification: ItemModification
                if item.isFavorite {
                    modification = ItemModification(action: .unfavorite, id: item.id)
                } else {
                    modification = ItemModification(action: .favorite, id: item.id)
                }
                
                strongSelf.dataProvider.performInMemoryWithoutResultType(endpoint: .modify(modification))
                item.isFavorite = !item.isFavorite
                success(true)
            }
            favoriteAction.title = item.isFavorite ? NSLocalizedString("Unfavorite", comment: "") : NSLocalizedString("Favorite", comment: "")
            return [favoriteAction]
        }
    }
    
    func buildTrailingActions(at indexPath: IndexPath, from tableView: UITableView) -> [UIContextualAction] {
        guard var item = self.dataSource?.item(at: indexPath) else { return [] }
        switch self.type {
        case .myList:
            let archiveAction = UIContextualAction(style: .normal, title: NSLocalizedString("Archive", comment: "")) { [weak self] (action, view, success) in
                guard let strongSelf = self else { return }
                let modification = ItemModification(action: .archive, id: item.id)
                strongSelf.dataProvider.performInMemoryWithoutResultType(endpoint: .modify(modification))
                item.status = "1"
                success(true)
            }
            return [archiveAction]
        case .favorites:
            return []
        case .archive:
            let unarchiveAction = UIContextualAction(style: .normal, title: NSLocalizedString("Unarchive", comment: "")) { [weak self] (action, view, success) in
                guard let strongSelf = self else { return }
                let modification = ItemModification(action: .readd, id: item.id)
                strongSelf.dataProvider.performInMemoryWithoutResultType(endpoint: .modify(modification))
                item.status = "0"
                success(true)
            }
            
            let deleteAction = UIContextualAction(style: .destructive, title: NSLocalizedString("Delete", comment: "")) { [weak self] (action, view, success) in
                guard let strongSelf = self else { return }
                let modification = ItemModification(action: .delete, id: item.id)
                strongSelf.dataProvider.performInMemoryWithoutResultType(endpoint: .modify(modification))
                item.status = "2"
                success(true)
            }
            return [unarchiveAction, deleteAction]
        }
    }
}
