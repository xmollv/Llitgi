//
//  ListViewController.swift
//  llitgi
//
//  Created by Xavi Moll on 25/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import UIKit
import SafariServices

enum TypeOfList {
    case all
    case myList
    case favorites
    case archive
    
    var position: Int {
        switch self {
        case .all: return 0
        case .myList: return 1
        case .favorites: return 2
        case .archive: return 3
        }
    }
}

class ListViewController: UITableViewController {
    
    //MARK: Private properties
    private let factory: ViewControllerFactory
    private let dataProvider: DataProvider
    private let userPreferences: PreferencesManager
    private let typeOfList: TypeOfList
    private let swipeActionManager: ListSwipeActionManager
    private let searchController = UISearchController(searchResultsController: nil)
    private var addButton: UIBarButtonItem? = nil
    private var loadingButton: UIBarButtonItem? = nil
    private var dataSource: ListDataSource?
    private var typeOfListForSearch: TypeOfList {
        didSet {
            self.dataSource?.typeOfList = self.typeOfListForSearch
        }
    }
    
    private lazy var customRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.pullToRefresh), for: .valueChanged)
        return refreshControl
    }()
    
    //MARK:- Lifecycle
    required init(factory: ViewControllerFactory, dependencies: Dependencies, type: TypeOfList) {
        self.factory = factory
        self.dataProvider = dependencies.dataProvider
        self.userPreferences = dependencies.userPreferences
        self.typeOfList = type
        self.typeOfListForSearch = type
        self.swipeActionManager = ListSwipeActionManager(dataProvider: dependencies.dataProvider)
        super.init(nibName: String(describing: ListViewController.self), bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.extendedLayoutIncludesOpaqueBars = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.pullToRefresh), name: .UIApplicationDidBecomeActive, object: nil)
        self.registerForPreviewing(with: self, sourceView: self.tableView)
        self.configureNavigationItems()
        self.configureSearchController()
        self.configureTableView()
        self.pullToRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.deselectRow(with: self.transitionCoordinator, animated: animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: Public methods
    func scrollToTop() {
        guard let numberOfItems = self.dataSource?.numberOfItems(), numberOfItems > 0 else { return }
        let firstIndexPath = IndexPath(row: 0, section: 0)
        self.tableView.scrollToRow(at: firstIndexPath, at: .top, animated: true)
    }
    
    //MARK: Private methods
    private func configureNavigationItems() {
        self.addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addButtonTapped(_:)))
        let loading = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        loading.tintColor = .black
        loading.startAnimating()
        self.loadingButton = UIBarButtonItem(customView: loading)
        self.navigationItem.rightBarButtonItem = self.addButton
    }
    
    private func configureTableView() {
        self.dataSource = ListDataSource(tableView: self.tableView,
                                         userPreferences: self.userPreferences,
                                         typeOfList: self.typeOfList,
                                         notifier: self.dataProvider.notifier(for: self.typeOfList))
        self.tableView.register(ListCell.self)
        self.tableView.delegate = self
        self.tableView.dataSource = self.dataSource
        self.tableView.tableFooterView = UIView()
        self.refreshControl = self.customRefreshControl
        if self.typeOfList == .myList {
            self.userPreferences.badgeDelegate = self
        }
    }
    
    private func configureSearchController() {
        self.searchController.searchBar.placeholder = L10n.General.search
        self.searchController.searchResultsUpdater = self
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.searchBar.scopeButtonTitles = [L10n.Titles.all, L10n.Titles.myList, L10n.Titles.favorites, L10n.Titles.archive]
        self.searchController.searchBar.selectedScopeButtonIndex = self.typeOfList.position
        self.searchController.searchBar.delegate = self
        self.navigationItem.searchController = self.searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.definesPresentationContext = true
    }
    
    @objc private func pullToRefresh() {
        self.dataProvider.syncLibrary { [weak self] (result: Result<[Item]>) in
            guard let strongSelf = self else { return }
            switch result {
            case .isSuccess: break
            case .isFailure(let error):
                Logger.log(error.localizedDescription, event: .error)
            }
            strongSelf.refreshControl?.endRefreshing()
        }
    }
    
    private func safariViewController(at indexPath: IndexPath) -> SFSafariViewController? {
        guard let url = self.dataSource?.item(at: indexPath)?.url else { return nil }
        let cfg = SFSafariViewController.Configuration()
        cfg.entersReaderIfAvailable = self.userPreferences.openReaderMode
        let sfs = SFSafariViewController(url: url, configuration: cfg)
        sfs.preferredControlTintColor = .black
        return sfs
    }
    
    @IBAction private func addButtonTapped(_ sender: UIButton) {
        self.navigationItem.rightBarButtonItem = self.loadingButton
        guard let url = UIPasteboard.general.url else {
            self.navigationItem.rightBarButtonItem = self.addButton

            let errorTitle = L10n.General.errorTitle
            let errorMessage = L10n.Add.invalidPasteboard

            let errorAlert = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
            let dimissTitle = L10n.General.dismiss
            errorAlert.addAction(UIAlertAction(title: dimissTitle, style: .default) { [weak self] (action) in
                self?.dismiss(animated: true, completion: nil)
            })
            self.present(errorAlert, animated: true, completion: nil)
            return
        }

        self.dataProvider.performInMemoryWithoutResultType(endpoint: .add(url)) { [weak self] (result: EmptyResult) in
            guard let strongSelf = self else { return }
            strongSelf.navigationItem.rightBarButtonItem = strongSelf.addButton
            switch result {
            case .isSuccess:
                strongSelf.pullToRefresh()
            case .isFailure(let error):
                Logger.log(error.localizedDescription, event: .error)
            }
        }
    }

}

//MARK:- UITableViewDelegate
extension ListViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch self.userPreferences.openLinksWith {
        case .safariViewController:
            guard let sfs = self.safariViewController(at: indexPath) else { return }
            self.present(sfs, animated: true, completion: nil)
        case .safari:
            guard let url = self.dataSource?.item(at: indexPath)?.url else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let item = self.dataSource?.item(at: indexPath) else { return nil }
        let actions = self.swipeActionManager.buildLeadingActions(for: item)
        return UISwipeActionsConfiguration(actions: actions)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let item = self.dataSource?.item(at: indexPath) else { return nil }
        let actions = self.swipeActionManager.buildTrailingActions(for: item)
        return UISwipeActionsConfiguration(actions: actions)
    }
}

//MARK:- UIViewControllerPreviewingDelegate
extension ListViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = self.tableView.indexPathForRow(at: location) else { return nil }
        previewingContext.sourceRect = self.tableView.rectForRow(at: indexPath)
        let sfs = self.safariViewController(at: indexPath)
        return sfs
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.present(viewControllerToCommit, animated: true, completion: nil)
    }
}

extension ListViewController: BadgeDelegate {
    func displayBadgeEnabled() {
        self.tableView.reloadData()
    }
}

extension ListViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //Reset to the default state
        self.searchController.searchBar.selectedScopeButtonIndex = self.typeOfList.position
        self.typeOfListForSearch = self.typeOfList
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        switch selectedScope {
        case 0:
            self.typeOfListForSearch = .all
        case 1:
            self.typeOfListForSearch = .myList
        case 2:
            self.typeOfListForSearch = .favorites
        case 3:
            self.typeOfListForSearch = .archive
        default:
            fatalError("This segmented control is not supported")
        }
        self.updateSearchResults(for: self.searchController)
    }
}

extension ListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text?.trimmingCharacters(in: .whitespaces) ?? ""
        if searchText.isEmpty {
            let notifier = self.dataProvider.notifier(for: self.typeOfListForSearch)
            self.dataSource?.establishNotifier(notifier: notifier, isSearch: false)
        } else {
            let notifier = self.dataProvider.notifier(for: self.typeOfListForSearch, filteredBy: searchText)
            self.dataSource?.establishNotifier(notifier: notifier, isSearch: true)
        }
        self.tableView.reloadData()
    }
}
