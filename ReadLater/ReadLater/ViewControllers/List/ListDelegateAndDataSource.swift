//
//  ListDelegateAndDataSource.swift
//  ReadLater
//
//  Created by Xavi Moll on 25/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import UIKit

class ListDelegateAndDataSource: NSObject {
    
    //MARK:- Private properties
    private var list: [Article] = []
    
    //MARK:- Public methods
    func add(_ articles: [Article]) {
        let sortedArticles = articles.sorted { $0.sortId < $1.sortId }
        self.list.append(contentsOf: sortedArticles)
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
    
}
