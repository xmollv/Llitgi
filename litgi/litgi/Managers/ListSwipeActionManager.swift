//
//  ListSwipeActionManager.swift
//  litgi
//
//  Created by Xavi Moll on 27/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import Foundation
import UIKit

class ListSwipeActionManager {
    
    private let dataSource: ListDataSource?
    private let dataProvider: DataProvider
    
    init(dataSource: ListDataSource?, dataProvider: DataProvider) {
        self.dataSource = dataSource
        self.dataProvider = dataProvider
    }
    
    func buildLeadingActions(at indexPath: IndexPath, from tableView: UITableView) -> [UIContextualAction] {
        guard var item = self.dataSource?.item(at: indexPath) else { return [] }
        
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
    
    func buildTrailingActions(at indexPath: IndexPath, from tableView: UITableView) -> [UIContextualAction] {
        guard var item = self.dataSource?.item(at: indexPath) else { return [] }
        let archiveAction = UIContextualAction(style: .normal, title: nil) { [weak self] (action, view, success) in
            guard let strongSelf = self else { return }

            let modification: ItemModification
            if item.status == "0" {
                modification = ItemModification(action: .archive, id: item.id)
                item.status = "1"
            } else {
                modification = ItemModification(action: .readd, id: item.id)
                item.status = "0"
            }
            strongSelf.dataProvider.performInMemoryWithoutResultType(endpoint: .modify(modification))
            success(true)
        }
        
        archiveAction.title = item.status == "0" ? NSLocalizedString("Archive", comment: "") : NSLocalizedString("Unarchive", comment: "")
        
        let deleteAction = UIContextualAction(style: .destructive, title: NSLocalizedString("Delete", comment: "")) { [weak self] (action, view, success) in
            guard let strongSelf = self else { return }
            let modification = ItemModification(action: .delete, id: item.id)
            strongSelf.dataProvider.performInMemoryWithoutResultType(endpoint: .modify(modification))
            item.status = "2"
            success(true)
        }
        
        return [archiveAction, deleteAction]
    }
}
