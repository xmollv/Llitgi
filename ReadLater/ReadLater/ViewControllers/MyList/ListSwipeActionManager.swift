//
//  ListSwipeActionBuilder.swift
//  ReadLater
//
//  Created by Xavi Moll on 27/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import Foundation
import UIKit

class ListSwipeActionManager {
    
    private let type: TypeOfList
    private let dataSource: ListDataSource
    private let dataProvider: DataProvider
    
    init(list: TypeOfList, dataSource: ListDataSource, dataProvider: DataProvider) {
        self.type = list
        self.dataSource = dataSource
        self.dataProvider = dataProvider
    }
    
    func buildLeadingActions(at indexPath: IndexPath, from tableView: UITableView) -> [UIContextualAction] {
        var article = self.dataSource.article(at: indexPath)
        switch self.type {
        case .myList:
            let favoriteAction = UIContextualAction(style: .normal, title: nil) { [weak self] (action, view, success) in
                guard let strongSelf = self else { return }
                
                let modification: ItemModification
                if article.isFavorite {
                    modification = ItemModification(action: .unfavorite, id: article.id)
                } else {
                    modification = ItemModification(action: .favorite, id: article.id)
                }
                
                strongSelf.dataProvider.perform(endpoint: .modify(modification))
                article.toggleFavoriteLocally()
                strongSelf.dataSource.replaceArticle(at: indexPath, with: article)
                tableView.reloadRows(at: [indexPath], with: .automatic)
                success(true)
            }
            favoriteAction.title = article.isFavorite ? NSLocalizedString("Unfavorite", comment: "") : NSLocalizedString("Favorite", comment: "")
            return [favoriteAction]
        case .favorites:
            let favoriteAction = UIContextualAction(style: .normal, title: nil) { [weak self] (action, view, success) in
                guard let strongSelf = self else { return }
                
                let modification = ItemModification(action: .unfavorite, id: article.id)
                strongSelf.dataProvider.perform(endpoint: .modify(modification))
                strongSelf.dataSource.removeArticle(at: indexPath)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                success(true)
            }
            favoriteAction.title = article.isFavorite ? NSLocalizedString("Unfavorite", comment: "") : NSLocalizedString("Favorite", comment: "")
            return [favoriteAction]
        case .archive:
            let favoriteAction = UIContextualAction(style: .normal, title: nil) { [weak self] (action, view, success) in
                guard let strongSelf = self else { return }
                
                let modification: ItemModification
                if article.isFavorite {
                    modification = ItemModification(action: .unfavorite, id: article.id)
                } else {
                    modification = ItemModification(action: .favorite, id: article.id)
                }
                
                strongSelf.dataProvider.perform(endpoint: .modify(modification))
                article.toggleFavoriteLocally()
                strongSelf.dataSource.replaceArticle(at: indexPath, with: article)
                tableView.reloadRows(at: [indexPath], with: .automatic)
                success(true)
            }
            favoriteAction.title = article.isFavorite ? NSLocalizedString("Unfavorite", comment: "") : NSLocalizedString("Favorite", comment: "")
            // Also add the option to readd
            return [favoriteAction]
        }
    }
    
    func buildTrailingActions(at indexPath: IndexPath, from tableView: UITableView) -> [UIContextualAction] {
        let article = self.dataSource.article(at: indexPath)
        switch self.type {
        case .myList:
            let archiveAction = UIContextualAction(style: .normal, title: NSLocalizedString("Archive", comment: "")) { [weak self] (action, view, success) in
                guard let strongSelf = self else { return }
                let modification = ItemModification(action: .archive, id: article.id)
                strongSelf.dataProvider.perform(endpoint: .modify(modification))
                strongSelf.dataSource.removeArticle(at: indexPath)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                success(true)
            }
            return [archiveAction]
        case .favorites:
            return []
        case .archive:
            let unarchiveAction = UIContextualAction(style: .normal, title: NSLocalizedString("Unarchive", comment: "")) { [weak self] (action, view, success) in
                guard let strongSelf = self else { return }
                let modification = ItemModification(action: .readd, id: article.id)
                strongSelf.dataProvider.perform(endpoint: .modify(modification))
                strongSelf.dataSource.removeArticle(at: indexPath)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                success(true)
            }
            
            let deleteAction = UIContextualAction(style: .destructive, title: NSLocalizedString("Delete", comment: "")) { [weak self] (action, view, success) in
                guard let strongSelf = self else { return }
                let modification = ItemModification(action: .delete, id: article.id)
                strongSelf.dataProvider.perform(endpoint: .modify(modification))
                strongSelf.dataSource.removeArticle(at: indexPath)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                success(true)
            }
            return [unarchiveAction, deleteAction]
        }
    }
}
