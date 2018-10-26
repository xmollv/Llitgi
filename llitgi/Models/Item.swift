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
    var timeUpdated: String { get }
    var isFavorite: Bool { get }
    var status: String { get }
    var tags: [Tag] { get }
    
    mutating func switchFavoriteStatus()
    mutating func changeStatus(to: String)
}

@objc(CoreDataItem)
final class CoreDataItem: NSManagedObject, Item, CoreDataManaged {
    
    //MARK: Private properties
    @NSManaged private var id_: String
    @NSManaged private var title_: String
    @NSManaged private var url_: String
    @NSManaged private var timeAdded_: String
    @NSManaged private var timeUpdated_: String
    @NSManaged private var isFavorite_: Bool
    @NSManaged private var status_: String
    @NSManaged private var tags_: NSSet
    
    //MARK: Public properties
    var id: String {
        get { return self.read(key: "id_")! }
        set { self.update(key: "id_", with: newValue) }
    }
    var title: String { return self.read(key: "title_")! }
    var url: URL {
        let stringUrl: String = self.read(key: "url_")!
        return URL(string: stringUrl)!
    }
    var timeAdded: String { return self.read(key: "timeAdded_")! }
    var timeUpdated: String { return self.read(key: "timeUpdated_")! }
    var isFavorite: Bool { return self.read(key: "isFavorite_")! }
    var status: String { return self.read(key: "status_")! }
    var tags: [Tag] {
        if let nssetTags: NSSet = self.read(key: "tags_") {
            return (nssetTags.allObjects as? [CoreDataTag])?.sorted{ $0.name < $1.name } ?? []
        } else {
            return []
        }
    }
    
    //MARK: Public methods
    func switchFavoriteStatus() {
        guard let context = self.managedObjectContext else { return }
        context.performAndWait {
            self.overrideLastTimeUpdated()
            self.isFavorite_ = !self.isFavorite_
            self.save(context)
        }
    }
    
    func changeStatus(to newStatus: String) {
        guard let context = self.managedObjectContext else { return }
        context.performAndWait {
            self.overrideLastTimeUpdated()
            self.status_ = newStatus
            self.save(context)
        }
    }
    
    //MARK: Private methods
    private func overrideLastTimeUpdated() {
        if let updatedTime = String(Date().timeIntervalSince1970).split(separator: ".").first {
            self.timeUpdated_ = String(updatedTime)
        }
    }
    
    private func save(_ context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch {
            Logger.log(error.localizedDescription, event: .error)
        }
    }
    
    //MARK:- CoreDataManaged conformance
    func update<T: Managed>(with json: JSONDictionary, on context: NSManagedObjectContext) -> T? {
        guard let urlAsString = (json["resolved_url"] as? String) ?? (json["given_url"] as? String),
            let _ = URL(string: urlAsString),
            let isFavoriteString = json["favorite"] as? String,
            let status = json["status"] as? String,
            let timeAdded = json["time_added"] as? String else {
                if let status = json["status"] as? String, status == "2" {} else {
                    Logger.log("Unable to update CoreDataItem: \(json.description).", event: .error)
                }
                return nil
        }
        
        context.performAndWait {
            if let pocketTitle = (json["resolved_title"] as? String) ?? (json["given_title"] as? String), pocketTitle != "" {
                self.title_ = pocketTitle
            } else {
                self.title_ = urlAsString
            }
            self.url_ = urlAsString
            self.status_ = status
            self.timeAdded_ = timeAdded
            self.timeUpdated_ = (json["time_updated"] as? String) ?? timeAdded
            self.isFavorite_ = (isFavoriteString == "0") ? false : true
            if let tagsDict = json["tags"] as? JSONDictionary {
                let tags = tagsDict.compactMap { CoreDataTag.create(with: $0.key, in: context) }
                self.tags_ = NSSet(array: tags)
            }
        }
        
        return self as? T
    }
}
