//
//  ListViewController.swift
//  ReadLater
//
//  Created by Xavi Moll on 25/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import UIKit
import SafariServices

enum TypeOfList {
    case myList
    case favorites
    case archive
}

class ListViewController: ViewController {

    //MARK:- IBOutlets
    @IBOutlet private var tableView: UITableView!
    
    //MARK: Private properties
    private let typeOfList: TypeOfList
    private let dataSource: ListDataSource
    private var swipeActionManager: ListSwipeActionManager?
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.fetchList), for: .valueChanged)
        return refreshControl
    }()
    
    //MARK:- Lifecycle
    required init(factory: ViewControllerFactory, dataProvider: DataProvider, type: TypeOfList) {
        self.typeOfList = type
        self.dataSource = ListDataSource()
        super.init(factory: factory, dataProvider: dataProvider)
        self.swipeActionManager = ListSwipeActionManager(list: type, dataSource: self.dataSource, dataProvider: self.dataProvider)
    }
    
    @available(*, unavailable)
    required init(factory: ViewControllerFactory, dataProvider: DataProvider) {
        fatalError("init(factory:dataProvider:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForPreviewing(with: self, sourceView: self.tableView)
        self.setupLocalizedStrings()
        self.configureTableView()
        self.fetchList()
    }
    
    //MARK: Private methods
    private func setupLocalizedStrings() {
        let title: String
        switch self.typeOfList {
        case .myList:
            title = NSLocalizedString("My List", comment: "")
        case .favorites:
            title = NSLocalizedString("Favorites", comment: "")
        case .archive:
            title = NSLocalizedString("Archive", comment: "")
        }
        self.title = title
    }
    
    private func configureTableView() {
        self.tableView.register(ListCell.self)
        self.tableView.delegate = self
        self.tableView.dataSource = self.dataSource
        self.tableView.tableFooterView = UIView()
        self.tableView.refreshControl = self.refreshControl
    }
    
    @objc private func fetchList() {
        let endpoint: PocketAPIEndpoint
        switch self.typeOfList {
        case .myList:
            endpoint = .getList
        case .favorites:
            endpoint = .getFavorites
        case .archive:
            endpoint = .getArchive
        }
        self.dataProvider.perform(endpoint: endpoint) { [weak self] (result: Result<[ArticleImplementation]>) in
            guard let strongSelf = self else { return }
            switch result {
            case .isSuccess(let articles):
                strongSelf.dataSource.replaceCurrentArticles(with: articles)
                strongSelf.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            case .isFailure(let error):
                //TODO: Properly handle the error
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
extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sfs = self.safariViewController(at: indexPath)
        self.present(sfs, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let swipeManager = self.swipeActionManager else { return nil }
        let actions = swipeManager.buildLeadingActions(at: indexPath, from: tableView)
        return UISwipeActionsConfiguration(actions: actions)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let swipeManager = self.swipeActionManager else { return nil }
        let actions = swipeManager.buildTrailingActions(at: indexPath, from: tableView)
        return UISwipeActionsConfiguration(actions: actions)
    }
}

//MARK:- UIViewControllerPreviewingDelegate
extension ListViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = self.tableView.indexPathForRow(at: location) else { return nil }
        let sfs = self.safariViewController(at: indexPath)
        return sfs
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.present(viewControllerToCommit, animated: true, completion: nil)
    }
}
