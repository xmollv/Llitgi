//
//  ListViewController.swift
//  llitgi
//
//  Created by Xavi Moll on 25/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import UIKit
import SafariServices

class BaseListViewController: UITableViewController, TableViewControllerNotifier {
    
    //MARK: Private properties
    let dataProvider: DataProvider
    let userManager: UserManager
    let theme: Theme
    let _notifier: CoreDataNotifier<CoreDataItem>
    private(set) var notifier: CoreDataNotifier<CoreDataItem>
    
    //MARK: Public properties
    var tagsModification: ((Item) -> Void)?
    var selectedTag: ((Tag) -> Void)?
    var safariToPresent: ((SFSafariViewController) -> Void)?
    
    //MARK:- Lifecycle
    init(notifier: CoreDataNotifier<CoreDataItem>, dataProvider: DataProvider, userManager: UserManager, theme: Theme) {
        self.dataProvider = dataProvider
        self.userManager = userManager
        self.theme = theme
        self._notifier = notifier
        self.notifier = notifier
        super.init(style: .plain)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.theme.statusBarStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.extendedLayoutIncludesOpaqueBars = true
        self.registerForPreviewing(with: self, sourceView: self.tableView)
        self.replaceCurrentNotifier(for: self._notifier)
        self.configureTableView()
        self.apply(self.theme)
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
        self.notifier.stopNotifying()
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
    
    private func safariViewController(at indexPath: IndexPath) -> SFSafariViewController {
        let item = self.notifier.element(at: indexPath)
        let cfg = SFSafariViewController.Configuration()
        cfg.entersReaderIfAvailable = self.userManager.openReaderMode
        let sfs = SFSafariViewController(url: item.url, configuration: cfg)
        sfs.preferredControlTintColor = self.theme.tintColor
        sfs.preferredBarTintColor = self.theme.backgroundColor
        return sfs
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
        cell.configure(with: item, theme: self.theme)
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
            // Open universal links instead of SFSafariViewController if possible
            UIApplication.shared.open(item.url, options: [.universalLinksOnly: true]) { [weak self] success in
                guard let self = self else { return }
                guard !success else {
                    self.tableView.deselectRow(at: indexPath, animated: true)
                    return
                }
                let sfs = self.safariViewController(at: indexPath)
                self.safariToPresent?(sfs)
            }
        case .safari:
            UIApplication.shared.open(item.url, options: [:], completionHandler: nil)
            self.tableView.deselectRow(at: indexPath, animated: true)
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

//MARK:- UIViewControllerPreviewingDelegate
extension BaseListViewController: UIViewControllerPreviewingDelegate {
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
