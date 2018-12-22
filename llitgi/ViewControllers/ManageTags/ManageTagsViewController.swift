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
    private lazy var cancelBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped(_:)))
        return barButtonItem
    }()
    
    private lazy var saveBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped(_:)))
        return barButtonItem
    }()
    
    //MARK:- Class properties
    let item: Item
    let dataProvider: DataProvider
    let themeManager: ThemeManager
    let completed: () -> Void
    private(set) var currentTags: [Tag] = []
    private(set) var availableTags: [Tag] = []
    
    
    //MARK:- Lifecycle
    init(item: Item, dataProvider: DataProvider, themeManager: ThemeManager, completed: @escaping () -> Void) {
        self.item = item
        self.dataProvider = dataProvider
        self.themeManager = themeManager
        self.completed = completed
        self.currentTags = item.tags
        self.availableTags = dataProvider.tags.filter { tag in
            return !item.tags.contains(where: { $0.name == tag.name} )
        }
        super.init(nibName: String(describing: ManageTagsViewController.self), bundle: Bundle(for: ManageTagsViewController.self))
        self.title = item.title
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
        self.navigationItem.leftBarButtonItem = self.cancelBarButtonItem
        self.navigationItem.rightBarButtonItem = self.saveBarButtonItem
        self.apply(self.themeManager.theme)
        self.themeManager.addObserver(self) { [weak self] theme in
            self?.apply(theme)
        }
        self.tableView.register(TagPickerCell.self)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.flashScrollIndicators()
    }
    
    @objc
    private func cancelTapped(_ sender: UIBarButtonItem) {
        self.completed()
    }
    
    @objc
    private func saveTapped(_ sender: UIBarButtonItem) {
        
    }
    
    private func apply(_ theme: Theme) {
        self.view.backgroundColor = theme.backgroundColor
        self.navigationController?.navigationBar.barStyle = theme.barStyle
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: theme.textTitleColor]
        self.toolBar.barStyle = theme.barStyle
        self.tableView.backgroundColor = theme.backgroundColor
        self.tableView.separatorColor = theme.separatorColor
        self.tableView.indicatorStyle = theme.indicatorStyle
        self.tableView.reloadData()
    }

}

//MARK:- UITableViewDelegate
extension ManageTagsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Section(section: indexPath.section) {
        case .currentTags:
            let tag = self.currentTags.remove(at: indexPath.row)
            self.availableTags.append(tag)
            self.availableTags.sort { $0.name < $1.name }
        case .availableTags:
            let tag = self.availableTags.remove(at: indexPath.row)
            self.currentTags.append(tag)
            self.currentTags.sort { $0.name < $1.name }
        }
        self.tableView.reloadData()
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = self.themeManager.theme.sectionHeaderBackground
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = self.themeManager.theme.textTitleColor
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        view.addSubview(label)
        
        label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 20).isActive = true
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: 5).isActive = true
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -5).isActive = true
        
        let tagSection = Section(section: section)
        switch tagSection {
        case .currentTags where self.currentTags.count > 0:
            label.text = tagSection.title
            return view
        case .availableTags where self.availableTags.count > 0:
            label.text = tagSection.title
            return view
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch Section(section: section) {
        case .currentTags:
            return self.currentTags.count > 0 ? UITableView.automaticDimension : 0
        case .availableTags:
            return self.availableTags.count > 0 ? UITableView.automaticDimension : 0
        }
    }
}
