//
//  TagsViewController.swift
//  llitgi
//
//  Created by Xavi Moll on 29/12/2018.
//  Copyright © 2018 xmollv. All rights reserved.
//

import UIKit
import Foundation

final class TagsViewController: UITableViewController, TableViewCoreDataNotifier {
    
    private lazy var loadingButton: UIBarButtonItem = {
        let loading = UIActivityIndicatorView(style: .gray)
        loading.startAnimating()
        return UIBarButtonItem(customView: loading)
    }()
    
    let dataProvider: DataProvider
    let userManager: UserManager
    let themeManager: ThemeManager
    let notifier: CoreDataNotifier<CoreDataTag>
    
    var settingsButtonTapped: (() -> Void)?
    var selectedTag: ((Tag) -> Void)?
    
    init(notifier: CoreDataNotifier<CoreDataTag>, dataProvider: DataProvider, userManager: UserManager, themeManager: ThemeManager) {
        self.dataProvider = dataProvider
        self.userManager = userManager
        self.themeManager = themeManager
        self.notifier = notifier
        super.init(style: .plain)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.themeManager.theme.statusBarStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.extendedLayoutIncludesOpaqueBars = true
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "settings"), landscapeImagePhone: #imageLiteral(resourceName: "settings_landscape"), style: .plain, target: self, action: #selector(self.displaySettings(_:)))
        self.configureTableView()
        self.notifier.delegate = self
        self.notifier.startNotifying()
        self.apply(self.themeManager.theme)
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
    
    //MARK: Private methods
    @IBAction private func displaySettings(_ sender: UIBarButtonItem) {
        self.settingsButtonTapped?()
    }
    
    private func apply(_ theme: Theme) {
        self.tableView.backgroundColor = theme.backgroundColor
        self.tableView.separatorColor = theme.separatorColor
        self.tableView.indicatorStyle = theme.indicatorStyle
        (self.loadingButton.customView as? UIActivityIndicatorView)?.color = theme.tintColor
        self.tableView.reloadData()
    }
    
    private func configureTableView() {
        self.tableView.register(TagPickerCell.self)
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorInset = .zero
    }
    
    private func blockUserInterfaceForNetwork(_ block: Bool) {
        if block {
            self.navigationItem.rightBarButtonItem = self.loadingButton
            self.tableView.isUserInteractionEnabled = false
        } else {
            self.navigationItem.rightBarButtonItem = nil
            self.tableView.isUserInteractionEnabled = true
        }
    }
    
    private func remove(tag: Tag, from items: [Item], then: @escaping (Bool) -> Void) {
        let modifications = items.map { ItemModification(action: .removeTags([tag.name]), id: $0.id) }
        
        self.dataProvider.performInMemoryWithoutResultType(endpoint: .modify(modifications)) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .isSuccess:
                strongSelf.dataProvider.syncLibrary { _ in
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    then(true)
                }
            case .isFailure:
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                strongSelf.presentErrorAlert()
                then(false)
            }
        }
    }
    
}

extension TagsViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.notifier.numberOfSections()
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notifier.numberOfElements(inSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tag: Tag = self.notifier.element(at: indexPath)
        let cell: TagPickerCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.configure(with: tag, theme: self.themeManager.theme)
        return cell
    }
}

extension TagsViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tag = self.notifier.element(at: indexPath)
        self.selectedTag?(tag)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: L10n.Actions.delete) { [weak self] (action, view, success) in
            guard let strongSelf = self else { return }
            
            let tag = strongSelf.notifier.element(at: indexPath)
            let affectedItems = strongSelf.dataProvider.items(with: tag)
            let message = String(format: L10n.Tags.removeWarning, arguments: [tag.name, affectedItems.count])
            let alertController = UIAlertController(title: L10n.Tags.remove,
                                                    message: message,
                                                    preferredStyle: .alert)
            let cancel = UIAlertAction(title: L10n.General.cancel, style: .cancel) { action in
                success(false)
            }
            let remove = UIAlertAction(title: L10n.Tags.remove, style: .destructive) { action in
                strongSelf.blockUserInterfaceForNetwork(true)
                strongSelf.remove(tag: tag, from: affectedItems) { completed in
                    if completed {
                        success(true)
                    } else {
                        strongSelf.presentErrorAlert()
                        success(false)
                    }
                    strongSelf.blockUserInterfaceForNetwork(false)
                }
            }
            alertController.addAction(cancel)
            alertController.addAction(remove)
            strongSelf.present(alertController, animated: true)
        }
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
        swipeConfiguration.performsFirstActionWithFullSwipe = false
        return swipeConfiguration
    }
}
