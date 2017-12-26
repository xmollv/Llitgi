//
//  ListViewController.swift
//  ReadLater
//
//  Created by Xavi Moll on 25/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import UIKit
import SafariServices

class MyListViewController: ViewController {

    //MARK:- IBOutlets
    @IBOutlet private var tableView: UITableView!
    
    //MARK:- Private properties
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.fetchList), for: .valueChanged)
        return refreshControl
    }()
    
    //MARK: Private properties
    private let dataSource = ListDataSource()
    
    //MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForPreviewing(with: self, sourceView: self.tableView)
        self.setupLocalizedStrings()
        self.configureTableView()
        self.fetchList()
    }
    
    //MARK: Private methods
    private func setupLocalizedStrings() {
        self.title = NSLocalizedString("My List", comment: "")
    }
    
    private func configureTableView() {
        self.tableView.register(ListCell.self)
        self.tableView.delegate = self
        self.tableView.dataSource = self.dataSource
        self.tableView.tableFooterView = UIView()
        self.tableView.refreshControl = self.refreshControl
    }
    
    @objc private func fetchList() {
        self.dataProvider.perform(endpoint: .getList) { [weak self] (result: Result<[ArticleImplementation]>) in
            guard let strongSelf = self else { return }
            switch result {
            case .isSuccess(let articles):
                strongSelf.dataSource.replaceCurrentArticles(with: articles)
                strongSelf.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            case .isFailure(let error):
                debugPrint(error)
            }
            strongSelf.refreshControl.endRefreshing()
        }
    }
    
    private func safariViewController(at indexPath: IndexPath) -> SFSafariViewController {
        let url = self.dataSource.article(at: indexPath).url
        let sfs = SFSafariViewController(url: url)
        sfs.preferredControlTintColor = .black
        return sfs
    }

}

//MARK:- UITableViewDelegate
extension MyListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sfs = self.safariViewController(at: indexPath)
        self.present(sfs, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var article = self.dataSource.article(at: indexPath)
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
            strongSelf.tableView.reloadRows(at: [indexPath], with: .automatic)
            success(true)
        }
        favoriteAction.title = article.isFavorite ? NSLocalizedString("Unfavorite", comment: "") : NSLocalizedString("Favorite", comment: "")
        return UISwipeActionsConfiguration(actions: [favoriteAction])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let article = self.dataSource.article(at: indexPath)
        let archiveAction = UIContextualAction(style: .normal, title: NSLocalizedString("Archive", comment: "")) { [weak self] (action, view, success) in
            guard let strongSelf = self else { return }
            let modification = ItemModification(action: .archive, id: article.id)
            strongSelf.dataProvider.perform(endpoint: .modify(modification))
            strongSelf.dataSource.removeArticle(at: indexPath)
            strongSelf.tableView.deleteRows(at: [indexPath], with: .automatic)
            success(true)
        }
        return UISwipeActionsConfiguration(actions: [archiveAction])
    }
}

//MARK:- UIViewControllerPreviewingDelegate
extension MyListViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = self.tableView.indexPathForRow(at: location) else {
            return nil
        }
        let sfs = self.safariViewController(at: indexPath)
        return sfs
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.present(viewControllerToCommit, animated: true, completion: nil)
    }
}
