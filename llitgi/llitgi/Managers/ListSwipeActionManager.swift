//
//  ListSwipeActionManager.swift
//  llitgi
//
//  Created by Xavi Moll on 27/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import Foundation
import UIKit

class ListSwipeActionManager {
    
    private let dataProvider: DataProvider
    
    init(dataProvider: DataProvider) {
        self.dataProvider = dataProvider
    }
    
    func buildLeadingActions(for item: Item, from tableView: UITableView) -> [UIContextualAction] {
        var item = item
        
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
        favoriteAction.title = item.isFavorite ? NSLocalizedString("unfavorite", comment: "") : NSLocalizedString("favorite", comment: "")
        favoriteAction.backgroundColor = UIColor(red: 242/255, green: 181/255, blue: 0/255, alpha: 1)
        
        return [favoriteAction]
    }
    
    func buildTrailingActions(for item: Item, from tableView: UITableView) -> [UIContextualAction] {
        var item = item
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
        
        archiveAction.title = item.status == "0" ? NSLocalizedString("to_archive", comment: "") : NSLocalizedString("unarchive", comment: "")
        
        let deleteAction = UIContextualAction(style: .destructive, title: NSLocalizedString("delete", comment: "")) { [weak self] (action, view, success) in
            guard let strongSelf = self else { return }
            let modification = ItemModification(action: .delete, id: item.id)
            strongSelf.dataProvider.performInMemoryWithoutResultType(endpoint: .modify(modification))
            item.status = "2"
            success(true)
        }
        
        return [archiveAction, deleteAction]
    }
}
