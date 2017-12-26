//
//  ListDataSource.swift
//  ReadLater
//
//  Created by Xavi Moll on 25/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import UIKit

class ListDataSource: NSObject {
    
    //MARK:- Private properties
    private var list: [Article] = []
    
    //MARK:- Public methods
    func article(at indexPath: IndexPath) -> Article {
        return list[indexPath.row]
    }
    
    func replaceCurrentArticles(with articles: [Article]) {
        let sortedArticles = articles.sorted { $0.sortId < $1.sortId }
        self.list = sortedArticles
    }
    
    func replaceArticle(at indexPath: IndexPath, with article: Article) {
        self.list[indexPath.row] = article
    }
    
    func removeArticle(at indexPath: IndexPath) {
        self.list.remove(at: indexPath.row)
    }
    
}

//MARK:- UITableViewDataSource
extension ListDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let article = self.article(at: indexPath)
        let cell: ListCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.configure(with: article)
        return cell
    }
}
