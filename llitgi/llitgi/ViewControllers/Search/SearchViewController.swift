//
//  SearchViewController.swift
//  llitgi
//
//  Created by Xavi Moll on 03/02/2018.
//  Copyright © 2018 xmollv. All rights reserved.
//

import UIKit
import SafariServices

class SearchViewController: ViewController {

    //MARK:- IBOutlets
    @IBOutlet private var searchTextField: UITextField!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var bottomConstraint: NSLayoutConstraint!
    
    //MARK:- Private properties
    private var searchResults: [Item] = []
    
    //MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.registerForPreviewing(with: self, sourceView: self.tableView)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardChanged(notification:)),
                                               name: .UIKeyboardWillChangeFrame,
                                               object: nil)
        self.configureSearchTextField()
        self.configureTableView()
    }
    
    //MARK:- Private methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.deselectRow(with: self.transitionCoordinator, animated: animated)
        self.searchTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.searchTextField.resignFirstResponder()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: Public methods
    func assignFirstResponderOnTextField() {
        self.searchTextField.becomeFirstResponder()
    }
    
    func searchFromSpotlight(item: Item) {
        self.searchTextField.text = item.title
        self.searchResults = [item]
        self.tableView.reloadData()
        self.open(url: item.url, animated: false)
    }
    
    //MARK:- Private methods
    private func configureSearchTextField() {
        self.searchTextField.delegate = self
        self.searchTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("search", comment: ""),
                                                                        attributes: [NSAttributedStringKey.foregroundColor: UIColor.black])
    }
    
    private func configureTableView() {
        self.tableView.register(ListCell.self)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        let gr = UITapGestureRecognizer(target: self, action: #selector(self.resignFirstResponderOnTextField))
        gr.cancelsTouchesInView = false
        self.tableView.addGestureRecognizer(gr)
    }
    
    @objc private func keyboardChanged(notification: NSNotification) {
        self.keyboardNotification(notification, constraint: self.bottomConstraint, view: self.view)
    }
    
    @objc private func resignFirstResponderOnTextField() {
        self.searchTextField.resignFirstResponder()
    }
    
    private func open(url: URL, animated: Bool = true) {
        switch self.userPreferences.openLinksWith {
        case .safariViewController:
            let sfs = SFSafariViewController(url: url)
            sfs.preferredControlTintColor = .black
            self.present(sfs, animated: animated, completion: nil)
        case .safari:
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

//MARK:- UITextFieldDelegate
extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.searchResults.removeAll()
        self.tableView.reloadData()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let textRange = Range(range, in: text) {
            let finalText = text.replacingCharacters(in: textRange, with: string)
            if finalText == "" {
                self.searchResults.removeAll()
            } else {
                self.searchResults = self.dataProvider.search(finalText)
            }
        } else {
            self.searchResults.removeAll()
        }
        self.tableView.reloadData()
        return true
    }
    
}

//MARK:- UITableViewDataSource
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfItems = self.searchResults.count
        if numberOfItems == 0 {
            let title = NSLocalizedString("no_results", comment: "")
            let subtitle = NSLocalizedString("no_results_search", comment: "")
            tableView.establishEmptyState(title: title, subtitle: subtitle)
        } else {
            tableView.backgroundView = nil
        }
        return numberOfItems
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.searchResults[indexPath.row]
        let cell: ListCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.configure(with: item)
        return cell
    }
    
}

//MARK:- UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.searchTextField.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = self.searchResults[indexPath.row].url
        self.open(url: url)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var item = self.searchResults[indexPath.row]
        
        let favoriteAction = UIContextualAction(style: .normal, title: nil) { [weak self] (action, view, success) in
            guard let strongSelf = self else { return }
            
            let modification: ItemModification
            if item.isFavorite {
                modification = ItemModification(action: .unfavorite, id: item.id)
            } else {
                modification = ItemModification(action: .favorite, id: item.id)
            }
            
            strongSelf.dataProvider.performInMemoryWithoutResultType(endpoint: .modify(modification))
            item.isFavorite = !item.isFavorite
            tableView.reloadRows(at: [indexPath], with: .automatic)
            success(true)
        }
        favoriteAction.title = item.isFavorite ? NSLocalizedString("unfavorite", comment: "") : NSLocalizedString("favorite", comment: "")
        
        return UISwipeActionsConfiguration(actions: [favoriteAction])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        var item = self.searchResults[indexPath.row]
        
        let archiveAction = UIContextualAction(style: .normal, title: nil) { [weak self] (action, view, success) in
            guard let strongSelf = self else { return }
            
            let modification: ItemModification
            if item.status == "0" {
                modification = ItemModification(action: .archive, id: item.id)
                item.status = "1"
            } else {
                modification = ItemModification(action: .readd, id: item.id)
                item.status = "0"
            }
            strongSelf.dataProvider.performInMemoryWithoutResultType(endpoint: .modify(modification))
            tableView.reloadRows(at: [indexPath], with: .automatic)
            success(true)
        }
        
        archiveAction.title = item.status == "0" ? NSLocalizedString("to_archive", comment: "") : NSLocalizedString("unarchive", comment: "")
        
        let deleteAction = UIContextualAction(style: .destructive, title: NSLocalizedString("delete", comment: "")) { [weak self] (action, view, success) in
            guard let strongSelf = self else { return }
            let modification = ItemModification(action: .delete, id: item.id)
            strongSelf.dataProvider.performInMemoryWithoutResultType(endpoint: .modify(modification))
            item.status = "2"
            strongSelf.searchResults.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .none)
            success(true)
        }
        
        return UISwipeActionsConfiguration(actions: [archiveAction, deleteAction])
    }
}

//MARK:- UIViewControllerPreviewingDelegate
extension SearchViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = self.tableView.indexPathForRow(at: location) else { return nil }
        previewingContext.sourceRect = self.tableView.rectForRow(at: indexPath)
        let url = self.searchResults[indexPath.row].url
        let sfs = SFSafariViewController(url: url)
        sfs.preferredControlTintColor = .black
        return sfs
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.present(viewControllerToCommit, animated: true, completion: nil)
    }
}
