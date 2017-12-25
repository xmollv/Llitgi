//
//  ListDelegateAndDataSource.swift
//  ReadLater
//
//  Created by Xavi Moll on 25/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import Foundation
import UIKit

class ListDelegateAndDataSource: NSObject {
    
    private var list: [Article] = []
    
    func add(_ articles: [Article]) {
        self.list.append(contentsOf: articles)
    }
    
}

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

extension ListDelegateAndDataSource: UITableViewDelegate {
    
}
