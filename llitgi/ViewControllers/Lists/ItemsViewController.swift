//
//  ItemsViewController.swift
//  llitgi
//
//  Created by Xavi Moll on 28/12/2018.
//  Copyright © 2018 xmollv. All rights reserved.
//

import UIKit
import Foundation

enum TypeOfList: Int {
    case all = 0
    case myList = 1
    case favorites = 2
    case archive = 3
    
    init(selectedScope: Int) {
        switch selectedScope {
        case 0: self = .all
        case 1: self = .myList
        case 2: self = .favorites
        case 3: self = .archive
        default: fatalError("You've fucked up.")
        }
    }
    
    var position: Int {
        return self.rawValue
    }
}

final class ItemsViewController: BaseListViewController {
    
    //MARK:- Private Properties
    private let typeOfList: TypeOfList
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
    
    //MARK:- Public properties
    var settingsButtonTapped: (() -> Void)?
    
    //MARK:- Lifecycle
    required init(notifier: CoreDataNotifier<CoreDataItem>, dataProvider: DataProvider, userManager: UserManager, themeManager: ThemeManager, type: TypeOfList) {
        self.typeOfList = type
        super.init(notifier: notifier, dataProvider: dataProvider, userManager: userManager, themeManager: themeManager)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.extendedLayoutIncludesOpaqueBars = true
        self.definesPresentationContext = true
        
        self.navigationItem.searchController = self.searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.rightBarButtonItem = self.addButton
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "settings"), landscapeImagePhone: #imageLiteral(resourceName: "settings_landscape"), style: .plain, target: self, action: #selector(self.displaySettings(_:)))
        
        if self.typeOfList == .myList {
            NotificationCenter.default.addObserver(self, selector: #selector(self.pullToRefresh), name: UIApplication.didBecomeActiveNotification, object: nil)
        }
        
        self.refreshControl = self.customRefreshControl
        
        self.pullToRefresh()
    }
    
    //MARK: Public methods
    override func apply(_ theme: Theme) {
        self.searchController.searchBar.keyboardAppearance = theme.keyboardAppearance
        self.customRefreshControl.tintColor = theme.pullToRefreshColor
        (self.loadingButton.customView as? UIActivityIndicatorView)?.color = theme.tintColor
        super.apply(theme)
    }
    
    //MARK:- IBActions
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
    
    //MARK:- Private methods
    @objc private func pullToRefresh() {
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
}

//MARK:- UISearchBarDelegate
extension ItemsViewController: UISearchBarDelegate {
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

//MARK:- UISearchResultsUpdating
extension ItemsViewController: UISearchResultsUpdating {
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
