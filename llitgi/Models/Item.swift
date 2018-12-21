//
//  Item.swift
//  llitgi
//
//  Created by Xavi Moll on 25/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import Foundation
import CoreData

enum ItemStatus: String {
    case normal = "0"
    case archived = "1"
    case deleted = "2"
}

protocol Item {
    
    var id: String { get }
    var title: String { get }
    var url: URL { get }
    var timeAdded: String { get }
    var timeUpdated: String { get }
    var isFavorite: Bool { get }
    var status: ItemStatus { get }
    var tags: [Tag] { get }
    
    mutating func switchFavoriteStatus()
    mutating func changeStatus(to: ItemStatus)
}

@objc(CoreDataItem)
final class CoreDataItem: Managed, Item {
    
    //MARK: Private properties
    @NSManaged private var id_: String
    @NSManaged private var title_: String
    @NSManaged private var url_: String
    @NSManaged private var timeAdded_: String
    @NSManaged private var timeUpdated_: String
    @NSManaged private var isFavorite_: Bool
    @NSManaged private var status_: String
    @NSManaged private var tags_: NSSet?
    
    //MARK: Public properties
    var id: String {
        get { return self.read(key: "id_")! }
    }
    var title: String { return self.read(key: "title_")! }
    var url: URL {
        let stringUrl: String = self.read(key: "url_")!
        return URL(string: stringUrl)!
    }
    var timeAdded: String { return self.read(key: "timeAdded_")! }
    var timeUpdated: String { return self.read(key: "timeUpdated_")! }
    var isFavorite: Bool { return self.read(key: "isFavorite_")! }
    var status: ItemStatus { return ItemStatus(rawValue: self.read(key: "status_")!)! }
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
    
    func changeStatus(to newStatus: ItemStatus) {
        guard let context = self.managedObjectContext else { return }
        context.performAndWait {
            self.overrideLastTimeUpdated()
            self.status_ = newStatus.rawValue
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
}

extension CoreDataItem {
    static func fetchOrCreate<T: Managed>(with json: JSONDictionary, on context: NSManagedObjectContext) -> T? {
        guard let id = json["item_id"] as? String else {
            Logger.log("Unable to find the id in the following item: \(json.description)", event: .error)
            return nil
        }
        var objectToReturn: CoreDataItem?
        if let fetchedObject: CoreDataItem = CoreDataItem.fetch(with: id, format: "id_ == %@", in: context) {
            objectToReturn = fetchedObject
        } else {
            objectToReturn = CoreDataItem.create(in: context)
        }
        objectToReturn?.id_ = id
        return objectToReturn as? T
    }
    
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
        
        if let pocketTitle = (json["resolved_title"] as? String) ?? (json["given_title"] as? String), pocketTitle != "" {
            self.title_ = pocketTitle
        } else {
            self.title_ = urlAsString
        }
        self.url_ = urlAsString
        self.status_ = status
        if self.timeAdded_ == "" {
            // We only update the timeAdded once, otherwise the FRC freaks out
            self.timeAdded_ = timeAdded
        }
        self.timeUpdated_ = (json["time_updated"] as? String) ?? timeAdded
        self.isFavorite_ = (isFavoriteString == "0") ? false : true
        if let tagsDict = json["tags"] as? JSONDictionary {
            let tags: [CoreDataTag] = tagsDict.compactMap { CoreDataTag.fetchOrCreate(with: [$0.key:""], on: context) }
            self.tags_ = NSSet(array: tags)
        } else {
            self.tags_ = NSSet()
        }
        
        return self as? T
    }
}
