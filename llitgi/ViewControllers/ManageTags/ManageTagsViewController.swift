//
//  ManageTagsViewController.swift
//  llitgi
//
//  Created by Xavi Moll on 22/12/2018.
//  Copyright © 2018 xmollv. All rights reserved.
//

import UIKit

private enum Section: Int, CaseIterable {
    case currentTags = 0
    case availableTags = 1
    
    init(section: Int) {
        switch section {
        case 0: self = .currentTags
        case 1: self = .availableTags
        default: fatalError("You've messed up.")
        }
    }
    
    var title: String {
        switch self {
        case .currentTags: return L10n.Tags.current
        case .availableTags: return L10n.Tags.available
        }
    }
}

class ManageTagsViewController: UIViewController {
    
    //MARK:- IBOutlets
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var toolBar: UIToolbar!
    @IBOutlet private var newTagBarButtonItem: UIBarButtonItem!
    
    //MARK:- Class properties
    let item: Item
    let dataProvider: DataProvider
    let themeManager: ThemeManager
    private(set) var currentTags: [Tag] = []
    private(set) var availableTags: [Tag] = []
    
    //MARK:- Lifecycle
    init(item: Item, dataProvider: DataProvider, themeManager: ThemeManager) {
        self.item = item
        self.dataProvider = dataProvider
        self.themeManager = themeManager
        self.currentTags = item.tags
        self.availableTags = dataProvider.tags
        super.init(nibName: String(describing: ManageTagsViewController.self), bundle: Bundle(for: ManageTagsViewController.self))
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
        self.tableView.register(TagPickerCell.self)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView()
    }

}

//MARK:- UITableViewDelegate
extension ManageTagsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}

//MARK:- UITableViewDataSource
extension ManageTagsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(section: section) {
        case .currentTags: return self.currentTags.count
        case .availableTags: return self.availableTags.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TagPickerCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        let tag: Tag
        switch Section(section: indexPath.section) {
        case .currentTags: tag = self.currentTags[indexPath.row]
        case .availableTags: tag = self.availableTags[indexPath.row]
        }
        cell.configure(with: tag, theme: self.themeManager.theme)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Section(section: section).title
    }
}
