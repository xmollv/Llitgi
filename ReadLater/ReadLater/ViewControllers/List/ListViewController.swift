//
//  ListViewController.swift
//  ReadLater
//
//  Created by Xavi Moll on 25/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import UIKit
import SafariServices

class ListViewController: ViewController {

    //MARK:- IBOutlets
    @IBOutlet private var tableView: UITableView!
    
    //MARK:- Private properties
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.fetchList), for: .valueChanged)
        return refreshControl
    }()
    
    //MARK: Private properties
    private let dataSource = ListDataSource()
    
    //MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForPreviewing(with: self, sourceView: self.tableView)
        self.setupLocalizedStrings()
        self.configureTableView()
        self.fetchList()
    }
    
    //MARK: Private methods
    private func setupLocalizedStrings() {
        self.title = NSLocalizedString("My List", comment: "")
    }
    
    private func configureTableView() {
        self.tableView.register(ListCell.self)
        self.tableView.delegate = self
        self.tableView.dataSource = self.dataSource
        self.tableView.tableFooterView = UIView()
        self.tableView.refreshControl = self.refreshControl
    }
    
    @objc private func fetchList() {
        self.dataProvider.perform(endpoint: .getList) { [weak self] (result: Result<[ArticleImplementation]>) in
            guard let strongSelf = self else { return }
            switch result {
            case .isSuccess(let articles):
                strongSelf.dataSource.replaceCurrentArticles(with: articles)
                strongSelf.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            case .isFailure(let error):
                debugPrint(error)
            }
            strongSelf.refreshControl.endRefreshing()
        }
    }
    
    private func safariViewController(at indexPath: IndexPath) -> SFSafariViewController {
        let url = self.dataSource.article(at: indexPath).url
        let sfs = SFSafariViewController(url: url)
        sfs.preferredControlTintColor = .black
        return sfs
    }

}

//MARK:- UITableViewDelegate
extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sfs = self.safariViewController(at: indexPath)
        self.present(sfs, animated: true, completion: nil)
    }
}

//MARK:- UIViewControllerPreviewingDelegate
extension ListViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = self.tableView.indexPathForRow(at: location) else {
            return nil
        }
        let sfs = self.safariViewController(at: indexPath)
        return sfs
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.present(viewControllerToCommit, animated: true, completion: nil)
    }
    
    
}
