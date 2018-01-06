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
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var addButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var tableView: UITableView!
    
    //MARK: Private properties
    private let typeOfList: TypeOfList
    private var dataSource: ListDataSource?
    private var swipeActionManager: ListSwipeActionManager?
    private var cellHeights: [IndexPath : CGFloat] = [:]
    
    // Pagination
    private var pageToRequest = 0
    private var isLastPage = false
    private var isCurrentlyFetching = false
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.pullToRefresh), for: .valueChanged)
        return refreshControl
    }()
    
    //MARK:- Lifecycle
    required init(factory: ViewControllerFactory, dataProvider: DataProvider, type: TypeOfList) {
        self.typeOfList = type
        super.init(factory: factory, dataProvider: dataProvider)
    }
    
    @available(*, unavailable)
    required init(factory: ViewControllerFactory, dataProvider: DataProvider) {
        fatalError("init(factory:dataProvider:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        registerForPreviewing(with: self, sourceView: self.tableView)
        self.configureUI(for: self.typeOfList)
        self.configureTableView()
        self.fetchList(andClearCache: true)
    }
    
    //MARK: Private methods
    private func configureUI(for type: TypeOfList) {
        let title: String
        switch type {
        case .myList:
            title = NSLocalizedString("My List", comment: "")
        case .favorites:
            title = NSLocalizedString("Favorites", comment: "")
            self.addButton.isHidden = true
        case .archive:
            title = NSLocalizedString("Archive", comment: "")
            self.addButton.isHidden = true
        }
        self.titleLabel.text = title
    }
    
    private func configureTableView() {
        self.dataSource = ListDataSource(tableView: self.tableView, notifier: self.dataProvider.notifier(for: self.typeOfList))
        self.swipeActionManager = ListSwipeActionManager(list: self.typeOfList, dataSource: self.dataSource, dataProvider: self.dataProvider)
        self.tableView.register(ListCell.self)
        self.tableView.delegate = self
        self.tableView.dataSource = self.dataSource
        self.tableView.tableFooterView = UIView()
        self.tableView.refreshControl = self.refreshControl
    }
    
    @objc private func pullToRefresh() {
        self.pageToRequest = 0
        self.isLastPage = false
        self.fetchList(andClearCache: true)
    }
    
    private func fetchList(andClearCache: Bool) {
        self.isCurrentlyFetching = true
        let endpoint: PocketAPIEndpoint
        switch self.typeOfList {
        case .myList:
            endpoint = .getList(page: self.pageToRequest)
        case .favorites:
            endpoint = .getFavorites(page: self.pageToRequest)
        case .archive:
            endpoint = .getArchive(page: self.pageToRequest)
        }
        
        self.dataProvider.perform(endpoint: endpoint, clearCachedData: andClearCache, typeOfList: self.typeOfList) { [weak self] (result: Result<[CoreDataItem]>) in
            guard let strongSelf = self else { return }
            switch result {
            case .isSuccess(let items):
                strongSelf.pageToRequest += 1
                if items.count == 0 {
                    strongSelf.isLastPage = true
                }
                Logger.log("Succes on: \(strongSelf.typeOfList)")
            case .isFailure(let error):
                Logger.log("Error on: \(strongSelf.typeOfList).\n\n Error: \(error)", event: .error)
            }
            strongSelf.refreshControl.endRefreshing()
            strongSelf.isCurrentlyFetching = false
        }
    }
    
    private func safariViewController(at indexPath: IndexPath) -> SFSafariViewController? {
        guard let url = self.dataSource?.item(at: indexPath)?.url else { return nil }
        let sfs = SFSafariViewController(url: url)
        sfs.preferredControlTintColor = .black
        return sfs
    }
    
    @IBAction private func addButtonTapped(_ sender: UIButton) {
        self.activityIndicator.isHidden = false
        self.addButton.isHidden = true
        guard let url = UIPasteboard.general.url else {
            Logger.log("The pasteboard doesn't contain any URL", event: .warning)
            self.activityIndicator.isHidden = true
            self.addButton.isHidden = false
            
            let errorTitle = NSLocalizedString("Oops!", comment: "")
            let errorMessage = NSLocalizedString("We're sorry, but your pasteboard doesn't contain any URLs. Please, copy a valid URL and try again.", comment: "")
            
            let errorAlert = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
            let dimissTitle = NSLocalizedString("Dismiss", comment: "")
            errorAlert.addAction(UIAlertAction(title: dimissTitle, style: .default) { [weak self] (action) in
                self?.dismiss(animated: true, completion: nil)
            })
            self.present(errorAlert, animated: true, completion: nil)
            return
        }
        
        self.dataProvider.performInMemoryWithoutResultType(endpoint: .add(url)) { [weak self] (result: EmptyResult) in
            guard let strongSelf = self else { return }
            strongSelf.activityIndicator.isHidden = true
            strongSelf.addButton.isHidden = false
            switch result {
            case .isSuccess:
                strongSelf.pullToRefresh()
            case .isFailure(let error):
                Logger.log("Error: \(error)", event: .error)
            }
        }
    }

}

//MARK:- UITableViewDelegate
extension ListViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.tableView.contentOffset.y > (self.tableView.contentSize.height - self.tableView.bounds.size.height) {
            guard self.isLastPage == false else { return }
            guard self.isCurrentlyFetching == false else { return }
            self.fetchList(andClearCache: false)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.cellHeights[indexPath] = cell.frame.size.height
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let height = self.cellHeights[indexPath] else { return UITableViewAutomaticDimension }
        return height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let sfs = self.safariViewController(at: indexPath) else { return }
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
