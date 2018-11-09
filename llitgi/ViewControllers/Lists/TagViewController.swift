//
//  TagViewController.swift
//  llitgi
//
//  Created by Xavi Moll on 28/10/2018.
//  Copyright © 2018 xmollv. All rights reserved.
//

import UIKit
import SafariServices

class TagViewController: UITableViewController {
    
    //MARK:- Private properties
    private let tag: Tag
    private let themeManager: ThemeManager
    private let userManager: UserManager
    
    //MARK:- Public properties
    var safariToPresent: ((SFSafariViewController) -> Void)?
    var selectedTag: ((Tag) -> Void)?
    
    //MARK:- Lifecycle
    init(tag: Tag, themeManager: ThemeManager, userManager: UserManager) {
        self.tag = tag
        self.themeManager = themeManager
        self.userManager = userManager
        super.init(nibName: String(describing: TagViewController.self), bundle: .main)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = tag.name.capitalized
        self.extendedLayoutIncludesOpaqueBars = true
        self.registerForPreviewing(with: self, sourceView: self.tableView)
        self.configureTableView()
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
    
    //MARK:- Private methods
    private func configureTableView() {
        self.tableView.register(ListCell.self)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
    }
    
    private func apply(_ theme: Theme) {
        self.tableView.backgroundColor = theme.backgroundColor
        self.tableView.separatorColor = theme.separatorColor
        self.tableView.indicatorStyle = theme.indicatorStyle
    }
    
    private func safariViewController(at indexPath: IndexPath) -> SFSafariViewController? {
        let url = self.tag.items[indexPath.row].url
        let cfg = SFSafariViewController.Configuration()
        cfg.entersReaderIfAvailable = self.userManager.openReaderMode
        let sfs = SFSafariViewController(url: url, configuration: cfg)
        sfs.preferredControlTintColor = self.themeManager.theme.tintColor
        sfs.preferredBarTintColor = self.themeManager.theme.backgroundColor
        return sfs
    }
}

extension TagViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tag.items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ListCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.configure(with: self.tag.items[indexPath.row], theme: self.themeManager.theme)
        cell.selectedTag = self.selectedTag
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch self.userManager.openLinksWith {
        case .safariViewController:
            guard let sfs = self.safariViewController(at: indexPath) else { return }
            self.safariToPresent?(sfs)
        case .safari:
            let url = self.tag.items[indexPath.row].url
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
//MARK:- UIViewControllerPreviewingDelegate
extension TagViewController: UIViewControllerPreviewingDelegate {
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
