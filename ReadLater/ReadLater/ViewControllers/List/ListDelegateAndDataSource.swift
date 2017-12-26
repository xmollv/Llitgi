//
//  ListDelegateAndDataSource.swift
//  ReadLater
//
//  Created by Xavi Moll on 25/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import UIKit

protocol URLOpenerDelegate: class {
    func open(_ url: URL)
}

class ListDelegateAndDataSource: NSObject {
    
    //MARK:- Private properties
    private var list: [Article] = []
    
    //MARK: Public properties
    weak var openerDelegate: URLOpenerDelegate? = nil
    
    //MARK:- Public methods
    func replaceCurrentArticles(with articles: [Article]) {
        let sortedArticles = articles.sorted { $0.sortId < $1.sortId }
        self.list = sortedArticles
    }
    
}

//MARK:- UITableViewDataSource
extension ListDelegateAndDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let article = list[indexPath.row]
        let cell: ListCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.configure(with: article)
        return cell
    }
}

//MARK:- UITableViewDelegate
extension ListDelegateAndDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let article = self.list[indexPath.row]
        self.openerDelegate?.open(article.url)
    }
}
