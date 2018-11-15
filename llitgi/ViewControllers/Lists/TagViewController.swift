//
//  TagViewController.swift
//  llitgi
//
//  Created by Xavi Moll on 28/10/2018.
//  Copyright © 2018 xmollv. All rights reserved.
//

import UIKit
import SafariServices

enum TagsSection: CaseIterable {
    case myList
    case archived
    
    init(section: Int) {
        switch section {
        case 0: self = .myList
        case 1: self = .archived
        default: fatalError("Usupported section")
        }
    }
    
    var sectionTitle: String {
        switch self {
        case .myList: return L10n.Titles.myList
        case .archived: return L10n.Titles.archive
        }
    }
}

class TagViewController: UITableViewController {
    
    //MARK:- Private properties
    private let tag: Tag
    private let themeManager: ThemeManager
    private let userManager: UserManager
    private let items: (myListItems: [Item], archivedItems: [Item])
    
    //MARK:- Public properties
    var safariToPresent: ((SFSafariViewController) -> Void)?
    var selectedTag: ((Tag) -> Void)?
    
    //MARK:- Lifecycle
    init(tag: Tag, themeManager: ThemeManager, userManager: UserManager) {
        self.tag = tag
        self.themeManager = themeManager
        self.userManager = userManager
        let myListItems = tag.items.filter{ $0.status == "0" }
        let archivedItems = tag.items.filter{ $0.status == "1" }
        self.items = (myListItems, archivedItems)
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
}

extension TagViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return TagsSection.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch TagsSection(section: section) {
        case .myList: return self.items.myListItems.count
        case .archived: return self.items.archivedItems.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ListCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        
        switch TagsSection(section: indexPath.section) {
        case .myList:
            cell.configure(with: self.items.myListItems[indexPath.row], theme: self.themeManager.theme)
        case .archived:
            cell.configure(with: self.items.archivedItems[indexPath.row], theme: self.themeManager.theme)
        }
        
        cell.selectedTag = self.selectedTag
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item: Item
        
        switch TagsSection(section: indexPath.section) {
        case .myList:
            item = self.items.myListItems[indexPath.row]
        case .archived:
            item = self.items.archivedItems[indexPath.row]
        }
        
        switch self.userManager.openLinksWith {
        case .safariViewController:
            let url = item.url
            let cfg = SFSafariViewController.Configuration()
            cfg.entersReaderIfAvailable = self.userManager.openReaderMode
            let sfs = SFSafariViewController(url: url, configuration: cfg)
            sfs.preferredControlTintColor = self.themeManager.theme.tintColor
            sfs.preferredBarTintColor = self.themeManager.theme.backgroundColor
            self.safariToPresent?(sfs)
        case .safari:
            let url = item.url
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let tagSection = TagsSection(section: section)
        switch tagSection {
        case .myList where self.items.myListItems.count > 0:
            return tagSection.sectionTitle
        case .archived where self.items.archivedItems.count > 0:
            return tagSection.sectionTitle
        default: return nil
        }
    }
}
