//
//  Item.swift
//  ReadLater
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
    var sortId: Int { get }
    var isFavorite: Bool { get set }
}

@objc(CoreDataItem)
final class CoreDataItem: NSManagedObject, Item, CoreDataManaged {
   
    //MARK:- Private properties
    @NSManaged private var id_: String
    @NSManaged private var title_: String
    @NSManaged private var url_: String
    @NSManaged private var sortId_: Int64
    @NSManaged private var isFavorite_: Bool
    @NSManaged private var status_: String
    
    //MARK:- Public properties
    var id: String {
        get { return self.id_ }
        set { self.id_ = newValue }
    }
    var title: String { return self.title_ }
    var url: URL { return URL(string: self.url_)! }
    var sortId: Int { return Int(self.sortId_) }
    var isFavorite: Bool {
        get { return self.isFavorite_ }
        set {
            //TODO: Do the core data dance to update and save the context
            self.isFavorite_ = newValue
        }
    }
    var status: String { return self.status_ }
    
    //MARK:- CoreDataManaged conformance
    func update<T: Managed>(with json: JSONDictionary, on: NSManagedObjectContext) -> T? {
        guard let sortId = json["sort_id"] as? Int,
            let urlAsString = (json["resolved_url"] as? String) ?? (json["given_url"] as? String),
            let isFavoriteString = json["favorite"] as? String,
            let status = json["status"] as? String else {
                Logger.log("Unable to update the CoreDataItem with ID: \(self.id).", event: .error)
                return nil
        }
        
        if let pocketTitle = (json["resolved_title"] as? String) ?? (json["given_title"] as? String), pocketTitle != "" {
            self.title_ = pocketTitle
        } else {
            self.title_ = NSLocalizedString("Unknown Title", comment: "")
        }
        
        self.url_ = urlAsString
        self.sortId_ = Int64(sortId)
        self.isFavorite_ = (isFavoriteString == "0") ? false : true
        self.status_ = status
        return self as? T
    }
}
