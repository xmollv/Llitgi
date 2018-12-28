//
//  ListViewController.swift
//  llitgi
//
//  Created by Xavi Moll on 25/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import UIKit
import SafariServices

class BaseListViewController: UITableViewController, TableViewCoreDataNotifier {
    
    //MARK: Private properties
    let dataProvider: DataProvider
    let userManager: UserManager
    let themeManager: ThemeManager
    let _notifier: CoreDataNotifier<CoreDataItem>
    private(set) var notifier: CoreDataNotifier<CoreDataItem>
    
    //MARK: Public properties
    var tagsModification: ((Item) -> Void)?
    var selectedTag: ((Tag) -> Void)?
    var safariToPresent: ((SFSafariViewController) -> Void)?
    
    //MARK:- Lifecycle
    init(notifier: CoreDataNotifier<CoreDataItem>, dataProvider: DataProvider, userManager: UserManager, themeManager: ThemeManager) {
        self.dataProvider = dataProvider
        self.userManager = userManager
        self.themeManager = themeManager
        self._notifier = notifier
        self.notifier = notifier
        super.init(style: .plain)
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
        self.extendedLayoutIncludesOpaqueBars = true
        self.replaceCurrentNotifier(for: self._notifier)
        self.configureTableView()
        self.apply(self.themeManager.theme)
        self.themeManager.addObserver(self) { [weak self] theme in
            self?.apply(theme)
        }
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
    func apply(_ theme: Theme) {
        self.tableView.backgroundColor = theme.backgroundColor
        self.tableView.separatorColor = theme.separatorColor
        self.tableView.indicatorStyle = theme.indicatorStyle
        self.tableView.reloadData()
    }
    
    func replaceCurrentNotifier(for notifier: CoreDataNotifier<CoreDataItem>) {
        self.notifier = notifier
        self.notifier.delegate = self
        self.notifier.startNotifying()
    }
    
    //MARK: Private methods
    private func configureTableView() {
        self.tableView.register(ListCell.self)
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorInset = .zero
    }
}

//MARK:- UITableViewDataSource
extension BaseListViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.notifier.numberOfSections()
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notifier.numberOfElements(inSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item: Item = self.notifier.element(at: indexPath)
        let cell: ListCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.configure(with: item, theme: self.themeManager.theme)
        cell.selectedTag = self.selectedTag
        return cell
    }
}

//MARK:- UITableViewDelegate
extension BaseListViewController {
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
