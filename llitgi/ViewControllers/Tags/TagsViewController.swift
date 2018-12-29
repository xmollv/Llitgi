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
    
    let dataProvider: DataProvider
    let userManager: UserManager
    let themeManager: ThemeManager
    let notifier: CoreDataNotifier<CoreDataTag>
    
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
//        self.registerForPreviewing(with: self, sourceView: self.tableView)
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
    
    func apply(_ theme: Theme) {
        self.tableView.backgroundColor = theme.backgroundColor
        self.tableView.separatorColor = theme.separatorColor
        self.tableView.indicatorStyle = theme.indicatorStyle
        self.tableView.reloadData()
    }
    
    //MARK: Private methods
    private func configureTableView() {
        self.tableView.register(TagPickerCell.self)
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorInset = .zero
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

//extension TagsViewController: UIViewControllerPreviewingDelegate {
//    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
//        guard let indexPath = self.tableView.indexPathForRow(at: location) else { return nil }
//        previewingContext.sourceRect = self.tableView.rectForRow(at: indexPath)
////        let sfs = self.safariViewController(at: indexPath)
////        return sfs
//        #warning("we need the next vc here")
//        return nil
//    }
//
//    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
//        self.present(viewControllerToCommit, animated: true, completion: nil)
//    }
//}
