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
    private var items: [Item] = []
    
    //MARK:- Public methods
    func item(at indexPath: IndexPath) -> Item {
        return items[indexPath.row]
    }
    
    func replaceCurrentItems(with items: [Item]) {
        let sortedItems = items.sorted { $0.sortId < $1.sortId }
        self.items = sortedItems
    }
    
    func replaceItem(at indexPath: IndexPath, with item: Item) {
        self.items[indexPath.row] = item
    }
    
    func removeItem(at indexPath: IndexPath) {
        self.items.remove(at: indexPath.row)
    }
    
}

//MARK:- UITableViewDataSource
extension ListDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.item(at: indexPath)
        let cell: ListCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.configure(with: item)
        return cell
    }
}
