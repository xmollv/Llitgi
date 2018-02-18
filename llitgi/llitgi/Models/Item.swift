//
//  Item.swift
//  llitgi
//
//  Created by Xavi Moll on 25/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import Foundation
import CoreData

protocol Item {
    var id: String { get }
    var title: String { get }
    var url: URL { get }
    var timeAdded: String { get }
    var isFavorite: Bool { get set }
    var status: String { get set }
}

@objc(CoreDataItem)
final class CoreDataItem: NSManagedObject, Item, CoreDataManaged {
    
    //MARK:- Private properties
    @NSManaged private var id_: String
    @NSManaged private var title_: String
    @NSManaged private var url_: String
    @NSManaged private var timeAdded_: String
    @NSManaged private var isFavorite_: Bool
    @NSManaged private var status_: String
    
    //MARK:- Public properties
    var id: String {
        get { return self.id_ }
        set { self.id_ = newValue }
    }
    var title: String { return self.title_ }
    var url: URL { return URL(string: self.url_)! }
    var timeAdded: String { return self.timeAdded_ }
    var isFavorite: Bool {
        get { return self.isFavorite_ }
        set {
            guard let context = self.managedObjectContext else { return }
            context.performAndWait {
                self.isFavorite_ = newValue
                do {
                    try context.save()
                } catch {
                    Logger.log("Unable to save the context when changing the favorite status.", event: .error)
                }
            }
        }
    }
    var status: String {
        get { return self.status_ }
        set {
            guard let context = self.managedObjectContext else { return }
            context.performAndWait {
                self.status_ = newValue
                do {
                    try context.save()
                } catch {
                    Logger.log("Unable to save the context when changing the archive/unarchive status.", event: .error)
                }
            }
        }
    }
    
    //MARK:- CoreDataManaged conformance
    func update<T: Managed>(with json: JSONDictionary, on: NSManagedObjectContext) -> T? {
        guard let urlAsString = (json["resolved_url"] as? String) ?? (json["given_url"] as? String),
            let isFavoriteString = json["favorite"] as? String,
            let status = json["status"] as? String,
            let timeAdded = json["time_added"] as? String else {
                if let status = json["status"] as? String, status == "2" {
                } else {
                    Logger.log("Unable to update the CoreDataItem with ID: \(self.id).", event: .error)
                }
                return nil
        }
        
        if let pocketTitle = (json["resolved_title"] as? String) ?? (json["given_title"] as? String), pocketTitle != "" {
            self.title_ = pocketTitle
        } else {
            self.title_ = NSLocalizedString("unknown_title", comment: "")
        }
        // This is to avoid saving URLs that can't be recreated later on
        guard let _ = URL(string: urlAsString) else { return nil }
        self.url_ = urlAsString
        self.status_ = status
        self.timeAdded_ = timeAdded
        self.isFavorite_ = (isFavoriteString == "0") ? false : true
        return self as? T
    }
}
