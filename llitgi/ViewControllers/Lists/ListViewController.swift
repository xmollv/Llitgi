//
//  ListViewController.swift
//  llitgi
//
//  Created by Xavi Moll on 25/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import UIKit
import SafariServices

class ListViewController: UITableViewController, TableViewCoreDataNotifier {
    
    //MARK: Private properties
    private let dataProvider: DataProvider
    private let userManager: UserManager
    private let themeManager: ThemeManager
    private let typeOfList: TypeOfList
    private let _notifier: CoreDataNotifier<CoreDataItem>
    private(set) var notifier: CoreDataNotifier<CoreDataItem>
    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = L10n.General.search
        sc.searchBar.scopeButtonTitles = [L10n.Titles.all, L10n.Titles.myList, L10n.Titles.favorites, L10n.Titles.archive]
        sc.searchBar.selectedScopeButtonIndex = self.typeOfList.position
        sc.searchBar.delegate = self
        return sc
    }()
    private lazy var customRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.pullToRefresh), for: .valueChanged)
        return refreshControl
    }()
    private lazy var addButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addButtonTapped(_:)))
    }()
    private lazy var loadingButton: UIBarButtonItem = {
        let loading = UIActivityIndicatorView(style: .gray)
        loading.startAnimating()
        return UIBarButtonItem(customView: loading)
    }()
    
    //MARK: Public properties
    var settingsButtonTapped: (() -> Void)?
    var tagsModification: ((Item) -> Void)?
    var selectedTag: ((Tag) -> Void)?
    var safariToPresent: ((SFSafariViewController) -> Void)?
    
    //MARK:- Lifecycle
    required init(dataProvider: DataProvider, userManager: UserManager, themeManager: ThemeManager, type: TypeOfList) {
        self.dataProvider = dataProvider
        self.userManager = userManager
        self.themeManager = themeManager
        self.typeOfList = type
        self._notifier = dataProvider.notifier(for: type)
        self.notifier = dataProvider.notifier(for: type)
        super.init(nibName: String(describing: ListViewController.self), bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.themeManager.removeObserver(self)
        NotificationCenter.default.removeObserver(self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.themeManager.theme.statusBarStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.replaceCurrentNotifier(for: self._notifier)
        
        self.extendedLayoutIncludesOpaqueBars = true
        self.definesPresentationContext = true
        
        self.navigationItem.searchController = self.searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.rightBarButtonItem = self.addButton
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "settings"), landscapeImagePhone: #imageLiteral(resourceName: "settings_landscape"), style: .plain, target: self, action: #selector(self.displaySettings(_:)))
        
        if self.typeOfList == .myList {
            NotificationCenter.default.addObserver(self, selector: #selector(self.pullToRefresh), name: UIApplication.didBecomeActiveNotification, object: nil)
        }
        
        self.configureTableView()
        self.apply(self.themeManager.theme)
        self.themeManager.addObserver(self) { [weak self] theme in
            self?.apply(theme)
        }
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
    
    //MARK: Public methods
    func scrollToTop() {
        guard self.notifier.numberOfElements(inSection: 0) > 0 else { return }
        let firstIndexPath = IndexPath(row: 0, section: 0)
        self.tableView.scrollToRow(at: firstIndexPath, at: .top, animated: true)
    }
    
    //MARK: Private methods
    private func apply(_ theme: Theme) {
        self.searchController.searchBar.keyboardAppearance = theme.keyboardAppearance
        self.tableView.backgroundColor = theme.backgroundColor
        self.tableView.separatorColor = theme.separatorColor
        self.tableView.indicatorStyle = theme.indicatorStyle
        self.customRefreshControl.tintColor = theme.pullToRefreshColor
        (self.loadingButton.customView as? UIActivityIndicatorView)?.color = theme.tintColor
        self.tableView.reloadData()
    }
    
    private func configureTableView() {
        self.tableView.register(ListCell.self)
        self.tableView.tableFooterView = UIView()
        self.refreshControl = self.customRefreshControl
    }
    
    func replaceCurrentNotifier(for notifier: CoreDataNotifier<CoreDataItem>) {
        self.notifier = notifier
        self.notifier.delegate = self
        self.notifier.startNotifying()
    }
    
    @objc
    private func pullToRefresh() {
        guard self.userManager.isLoggedIn else { return }
        self.dataProvider.syncLibrary { [weak self] (result: Result<[Item]>) in
            switch result {
            case .isSuccess: break
            case .isFailure(let error):
                Logger.log(error.localizedDescription, event: .error)
            }
            self?.customRefreshControl.endRefreshing()
        }
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

//MARK:- UITableViewDataSource
extension ListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notifier.numberOfElements(inSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item: Item = self.notifier.element(at: indexPath)
        let cell: ListCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.configure(with: item, theme: self.themeManager.theme)
        return cell
    }
}

//MARK:- UITableViewDelegate
extension ListViewController {
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let listCell = cell as? ListCell {
            listCell.selectedTag = self.selectedTag
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item: Item = self.notifier.element(at: indexPath)
        switch self.userManager.openLinksWith {
        case .safariViewController:
            let cfg = SFSafariViewController.Configuration()
            cfg.entersReaderIfAvailable = self.userManager.openReaderMode
            let sfs = SFSafariViewController(url: item.url, configuration: cfg)
            sfs.preferredControlTintColor = self.themeManager.theme.tintColor
            sfs.preferredBarTintColor = self.themeManager.theme.backgroundColor
            self.safariToPresent?(sfs)
        case .safari:
            UIApplication.shared.open(item.url, options: [:], completionHandler: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var item: Item = self.notifier.element(at: indexPath)
        
        let favoriteAction = UIContextualAction(style: .normal, title: nil) { [weak self] (action, view, success) in
            guard let strongSelf = self else { return }
            
            let modification: ItemModification
            if item.isFavorite {
                modification = ItemModification(action: .unfavorite, id: item.id)
            } else {
                modification = ItemModification(action: .favorite, id: item.id)
            }
            
            strongSelf.dataProvider.performInMemoryWithoutResultType(endpoint: .modify([modification]))
            item.switchFavoriteStatus()
            success(true)
        }
        favoriteAction.title = item.isFavorite ? L10n.Actions.unfavorite : L10n.Actions.favorite
        favoriteAction.backgroundColor = UIColor(displayP3Red: 194/255, green: 147/255, blue: 61/255, alpha: 1)
        
        let tagsModificationAction = UIContextualAction(style: .normal, title: L10n.Actions.tags) { [weak self] (action, view, success) in
            self?.tagsModification?(item)
            success(true)
        }
        tagsModificationAction.backgroundColor = UIColor(displayP3Red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [favoriteAction, tagsModificationAction])
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var item: Item = self.notifier.element(at: indexPath)
        
        let archiveAction = UIContextualAction(style: .normal, title: nil) { [weak self] (action, view, success) in
            guard let strongSelf = self else { return }
            
            let modification: ItemModification
            if item.status == .normal {
                modification = ItemModification(action: .archive, id: item.id)
                item.changeStatus(to: .archived)
            } else {
                modification = ItemModification(action: .readd, id: item.id)
                item.changeStatus(to: .normal)
            }
            strongSelf.dataProvider.performInMemoryWithoutResultType(endpoint: .modify([modification]))
            success(true)
        }
        archiveAction.title = item.status == .normal ? L10n.Actions.archive : L10n.Actions.unarchive
        
        let deleteAction = UIContextualAction(style: .destructive, title: L10n.Actions.delete) { [weak self] (action, view, success) in
            guard let strongSelf = self else { return }
            let modification = ItemModification(action: .delete, id: item.id)
            strongSelf.dataProvider.performInMemoryWithoutResultType(endpoint: .modify([modification]))
            item.changeStatus(to: .deleted)
            success(true)
        }
        
        return UISwipeActionsConfiguration(actions: [archiveAction, deleteAction])
    }
}

extension ListViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchController.searchBar.selectedScopeButtonIndex = self.typeOfList.position
        self.replaceCurrentNotifier(for: self._notifier)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        self.updateSearchResults(for: self.searchController)
    }
}

extension ListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let typeOfListForSearch = TypeOfList(selectedScope: searchController.searchBar.selectedScopeButtonIndex)
        if searchText.isEmpty {
            self.replaceCurrentNotifier(for: self.dataProvider.notifier(for: typeOfListForSearch))
        } else {
            self.replaceCurrentNotifier(for: self.dataProvider.notifier(for: typeOfListForSearch, filteredBy: searchText))
        }
        self.tableView.reloadData()
    }
}
