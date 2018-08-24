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
    private let dataProvider: DataProvider
    private let userManager: UserManager
    private let themeManager: ThemeManager
    private let typeOfList: TypeOfList
    private let searchController = UISearchController(searchResultsController: nil)
    private var addButton: UIBarButtonItem? = nil
    private var loadingButton: UIBarButtonItem? = nil
    private var dataSource: ListDataSource? = nil
    private var cellHeights: [IndexPath : CGFloat] = [:]
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
    
    //MARK: Public properties
    var settingsButtonTapped: (() -> Void)?
    var safariToPresent: ((SFSafariViewController) -> Void)?
    
    //MARK:- Lifecycle
    required init(dataProvider: DataProvider, userManager: UserManager,themeManager: ThemeManager, type: TypeOfList) {
        self.dataProvider = dataProvider
        self.userManager = userManager
        self.themeManager = themeManager
        self.typeOfList = type
        self.typeOfListForSearch = type
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
        self.apply(self.themeManager.theme)
        self.themeManager.themeChanged = { [weak self] theme in
            self?.apply(theme)
        }
        self.configureNavigationItems()
        self.configureSearchController()
        self.configureTableView()
        self.pullToRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.deselectRow(with: self.transitionCoordinator, animated: animated)
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        if newCollection.horizontalSizeClass == .compact {
            self.tableView.deselectRow(with: coordinator, animated: true)
        }
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
    private func apply(_ theme: Theme) {
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:theme.textTitleColor]
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor:theme.textTitleColor]
        self.tableView.backgroundColor = theme.backgroundColor
        self.tableView.reloadData()
    }
    
    private func configureNavigationItems() {
        self.addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addButtonTapped(_:)))
        let loading = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        loading.tintColor = .black
        loading.startAnimating()
        self.loadingButton = UIBarButtonItem(customView: loading)
        self.navigationItem.rightBarButtonItem = self.addButton
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "settings"), landscapeImagePhone: #imageLiteral(resourceName: "settings_landscape"), style: .plain, target: self, action: #selector(self.displaySettings(_:)))
    }
    
    private func configureTableView() {
        self.dataSource = ListDataSource(tableView: self.tableView,
                                         userPreferences: self.userManager,
                                         themeManager: self.themeManager,
                                         typeOfList: self.typeOfList,
                                         notifier: self.dataProvider.notifier(for: self.typeOfList))
        self.tableView.register(ListCell.self)
        self.tableView.delegate = self
        self.tableView.dataSource = self.dataSource
        self.tableView.tableFooterView = UIView()
        self.refreshControl = self.customRefreshControl
        if self.typeOfList == .myList {
            self.userManager.badgeDelegate = self
        }
    }
    
    private func configureSearchController() {
        self.searchController.searchResultsUpdater = self
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.searchBar.placeholder = L10n.General.search
        self.searchController.searchBar.scopeButtonTitles = [L10n.Titles.all, L10n.Titles.myList, L10n.Titles.favorites, L10n.Titles.archive]
        self.searchController.searchBar.selectedScopeButtonIndex = self.typeOfList.position
        self.searchController.searchBar.delegate = self
        self.definesPresentationContext = true
        self.navigationItem.searchController = self.searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    @objc private func pullToRefresh() {
        guard self.userManager.isLoggedIn else { return }
        self.dataProvider.syncLibrary { [weak self] (result: Result<[Item]>) in
            switch result {
            case .isSuccess: break
            case .isFailure(let error):
                Logger.log(error.localizedDescription, event: .error)
            }
            self?.refreshControl?.endRefreshing()
        }
    }
    
    private func safariViewController(at indexPath: IndexPath) -> SFSafariViewController? {
        guard let url = self.dataSource?.item(at: indexPath)?.url else { return nil }
        let cfg = SFSafariViewController.Configuration()
        cfg.entersReaderIfAvailable = self.userManager.openReaderMode
        let sfs = SFSafariViewController(url: url, configuration: cfg)
        sfs.preferredControlTintColor = .black
        sfs.preferredBarTintColor = .white
        return sfs
    }
    
    @IBAction private func addButtonTapped(_ sender: UIButton) {
        self.navigationItem.rightBarButtonItem = self.loadingButton
        guard let url = UIPasteboard.general.url else {
            self.navigationItem.rightBarButtonItem = self.addButton
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            self.presentErrorAlert(with: L10n.General.errorTitle, and: L10n.Add.invalidPasteboard)
            return
        }

        self.dataProvider.performInMemoryWithoutResultType(endpoint: .add(url)) { [weak self] (result: EmptyResult) in
            guard let strongSelf = self else { return }
            strongSelf.navigationItem.rightBarButtonItem = strongSelf.addButton
            switch result {
            case .isSuccess:
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                strongSelf.pullToRefresh()
            case .isFailure(let error):
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                strongSelf.presentErrorAlert()
                Logger.log(error.localizedDescription, event: .error)
            }
        }
    }
    
    @IBAction private func displaySettings(_ sender: UIBarButtonItem) {
        self.settingsButtonTapped?()
    }

}

//MARK:- UITableViewDelegate
extension ListViewController {
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.cellHeights[indexPath] = cell.frame.size.height
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let height = self.cellHeights[indexPath] else { return UITableViewAutomaticDimension }
        return height
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch self.userManager.openLinksWith {
        case .safariViewController:
            guard let sfs = self.safariViewController(at: indexPath) else { return }
            self.safariToPresent?(sfs)
        case .safari:
            guard let url = self.dataSource?.item(at: indexPath)?.url else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard var item = self.dataSource?.item(at: indexPath) else { return nil }
        let favoriteAction = UIContextualAction(style: .normal, title: nil) { [weak self] (action, view, success) in
            guard let strongSelf = self else { return }
            
            let modification: ItemModification
            if item.isFavorite {
                modification = ItemModification(action: .unfavorite, id: item.id)
            } else {
                modification = ItemModification(action: .favorite, id: item.id)
            }
            
            strongSelf.dataProvider.performInMemoryWithoutResultType(endpoint: .modify(modification))
            item.switchFavoriteStatus()
            success(true)
        }
        favoriteAction.title = item.isFavorite ? L10n.Actions.unfavorite : L10n.Actions.favorite
        favoriteAction.backgroundColor = UIColor(red: 242/255, green: 181/255, blue: 0/255, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [favoriteAction])
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard var item = self.dataSource?.item(at: indexPath) else { return nil }
        
        let archiveAction = UIContextualAction(style: .normal, title: nil) { [weak self] (action, view, success) in
            guard let strongSelf = self else { return }
            
            let modification: ItemModification
            if item.status == "0" {
                modification = ItemModification(action: .archive, id: item.id)
                item.changeStatus(to: "1")
            } else {
                modification = ItemModification(action: .readd, id: item.id)
                item.changeStatus(to: "0")
            }
            strongSelf.dataProvider.performInMemoryWithoutResultType(endpoint: .modify(modification))
            success(true)
        }
        archiveAction.title = item.status == "0" ? L10n.Actions.archive : L10n.Actions.unarchive
        
        let deleteAction = UIContextualAction(style: .destructive, title: L10n.Actions.delete) { [weak self] (action, view, success) in
            guard let strongSelf = self else { return }
            let modification = ItemModification(action: .delete, id: item.id)
            strongSelf.dataProvider.performInMemoryWithoutResultType(endpoint: .modify(modification))
            item.changeStatus(to: "2")
            success(true)
        }
        
        return UISwipeActionsConfiguration(actions: [archiveAction, deleteAction])
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
