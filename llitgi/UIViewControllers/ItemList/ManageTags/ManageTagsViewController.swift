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
    private lazy var loadingButton: UIBarButtonItem = {
        let loading = UIActivityIndicatorView(style: .gray)
        loading.startAnimating()
        return UIBarButtonItem(customView: loading)
    }()
    
    //MARK:- Class properties
    let item: Item
    let dataProvider: DataProvider
    let theme: Theme
    let completed: () -> Void
    private(set) var currentTags: [Tag] = []
    private(set) var availableTags: [Tag] = []
    
    
    //MARK:- Lifecycle
    init(item: Item, dataProvider: DataProvider, theme: Theme, completed: @escaping () -> Void) {
        self.item = item
        self.dataProvider = dataProvider
        self.theme = theme
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
        return self.theme.statusBarStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = self.cancelBarButtonItem
        self.navigationItem.rightBarButtonItem = self.saveBarButtonItem
        self.apply(self.theme)
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
        self.blockUserInterfaceForNetwork(true)

        let itemModification = ItemModification.init(action: .replaceTags(self.currentTags.map{ $0.name }), id: self.item.id)
        self.dataProvider.performInMemoryWithoutResultType(endpoint: .modify([itemModification])) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success:
                strongSelf.dataProvider.syncLibrary { _ in
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    strongSelf.completed()
                }
            case .failure:
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                strongSelf.blockUserInterfaceForNetwork(false)
                strongSelf.presentErrorAlert()
            }
        }
    }
    
    @IBAction func newTagTapped(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: L10n.Tags.newTagTitle,
                                                message: nil,
                                                preferredStyle: .alert)
        
        alertController.addTextField { [weak self] (textField) in
            guard let strongSelf = self else { return }
            textField.keyboardAppearance = strongSelf.theme.keyboardAppearance
        }
        let cancel = UIAlertAction(title: L10n.General.cancel, style: .cancel, handler: nil)
        let add = UIAlertAction(title: L10n.General.add, style: .default) { [weak self, weak alertController] (action) in
            guard let strongSelf = self else { return }
            guard let text = alertController?.textFields?.first?.text, text != "" else { return }
            if let index = strongSelf.availableTags.firstIndex(where: { $0.name == text }) {
                let tag = strongSelf.availableTags.remove(at: index)
                strongSelf.currentTags.append(tag)
                strongSelf.currentTags.sort { $0.name < $1.name }
            } else if strongSelf.currentTags.firstIndex(where: { $0.name == text }) == nil {
                strongSelf.currentTags.append(InMemoryTag(name: text))
                strongSelf.currentTags.sort { $0.name < $1.name }
            }
            strongSelf.tableView.reloadData()
        }
        alertController.addAction(cancel)
        alertController.addAction(add)
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func apply(_ theme: Theme) {
        self.view.backgroundColor = theme.backgroundColor
        self.navigationController?.navigationBar.barStyle = theme.barStyle
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: theme.textTitleColor]
        (self.loadingButton.customView as? UIActivityIndicatorView)?.color = theme.tintColor
        self.toolBar.barStyle = theme.barStyle
        self.tableView.backgroundColor = theme.backgroundColor
        self.tableView.separatorColor = theme.separatorColor
        self.tableView.indicatorStyle = theme.indicatorStyle
        self.tableView.reloadData()
    }
    
    private func blockUserInterfaceForNetwork(_ block: Bool) {
        if block {
            self.navigationItem.rightBarButtonItem = self.loadingButton
            self.newTagBarButtonItem.isEnabled = false
            self.tableView.isUserInteractionEnabled = false
        } else {
            self.navigationItem.rightBarButtonItem = self.saveBarButtonItem
            self.newTagBarButtonItem.isEnabled = true
            self.tableView.isUserInteractionEnabled = true
        }
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
        cell.configure(with: tag, theme: self.theme)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeaderView = SectionHeaderView(theme: self.theme)
        
        let tagSection = Section(section: section)
        switch tagSection {
        case .currentTags where self.currentTags.count > 0:
            sectionHeaderView.text = tagSection.title
            return sectionHeaderView
        case .availableTags where self.availableTags.count > 0:
            sectionHeaderView.text = tagSection.title
            return sectionHeaderView
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

private struct InMemoryTag: Tag {
    let name: String
    let items: [Item] = []
}
