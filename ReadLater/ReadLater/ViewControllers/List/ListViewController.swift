//
//  ListViewController.swift
//  ReadLater
//
//  Created by Xavi Moll on 25/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import UIKit

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
    private let delegateAndDataSource = ListDelegateAndDataSource()
    
    //MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
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
        self.tableView.delegate = self.delegateAndDataSource
        self.tableView.dataSource = self.delegateAndDataSource
        self.tableView.tableFooterView = UIView()
        self.tableView.refreshControl = self.refreshControl
    }
    
    @objc private func fetchList() {
        self.dataProvider.perform(endpoint: .getList) { [weak self] (result: Result<[ArticleImplementation]>) in
            guard let strongSelf = self else { return }
            switch result {
            case .isSuccess(let articles):
                strongSelf.delegateAndDataSource.replaceCurrentArticles(with: articles)
                strongSelf.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            case .isFailure(let error):
                debugPrint(error)
            }
            strongSelf.refreshControl.endRefreshing()
        }
    }

}
