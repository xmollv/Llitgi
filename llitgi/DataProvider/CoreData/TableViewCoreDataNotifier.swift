//
//  AutomaticCoreDataNotifier.swift
//  llitgi
//
//  Created by Xavi Moll on 02/12/2018.
//  Copyright © 2018 xmollv. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol TableViewCoreDataNotifier: CoreDataNotifierDelegate {
    //The ! is due to how UITableViewController declares it's own UITableView :facepalm:
    var tableView: UITableView! { get set }
    var notifier: CoreDataNotifier { get }
}

extension TableViewCoreDataNotifier {
    func willChangeContent() {
        self.tableView.beginUpdates()
    }
    
    func didChangeContent(_ change: CoreDataNotifierChange) {
        switch change {
        case .insert(let indexPath):
            self.tableView.insertRows(at: [indexPath], with: .automatic)
        case .delete(let indexPath):
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        case .update(let indexPath):
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        case .move(let from, let to):
            self.tableView.moveRow(at: from, to: to)
        }
    }
    
    func endChangingContent() {
        self.tableView.endUpdates()
    }
    
    func startNotifyingFailed(with error: Error) {
        self.notifier.startNotifying()
    }
}
