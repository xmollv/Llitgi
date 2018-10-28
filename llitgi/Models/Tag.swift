//
//  Tag.swift
//  llitgi
//
//  Created by Xavi Moll on 26/10/2018.
//  Copyright © 2018 xmollv. All rights reserved.
//

import Foundation
import CoreData

protocol Tag {
    var name: String { get }
    var items: [Item] { get }
}

@objc(CoreDataTag)
final class CoreDataTag: Managed, Tag {
    
    //MARK: Private properties
    @NSManaged private var name_: String
    @NSManaged private var items_: [CoreDataItem]
    
    var name: String {
        get { return self.read(key: "name_")! }
        set { self.update(key: "name_", with: newValue) }
    }
    var items: [Item] {
        if let nssetItems: NSSet = self.read(key: "items_") {
            return (nssetItems.allObjects as? [CoreDataItem])?.sorted { $0.timeAdded > $1.timeAdded } ?? []
        } else {
            return []
        }
    }
}

extension CoreDataTag {
    static func fetchOrCreate<T: Managed>(with json: JSONDictionary, on context: NSManagedObjectContext) -> T? {
        guard let id = json.keys.first else {
            Logger.log("Unable to find the id in the following item: \(json.description)", event: .error)
            return nil
        }
        var objectToReturn: CoreDataTag?
        if let fetchedObject: CoreDataTag = CoreDataTag.fetch(with: id, format: "name_ == %@", in: context) {
            objectToReturn = fetchedObject
        } else {
            objectToReturn = CoreDataTag.create(in: context)
        }
        objectToReturn?.name = id
        return objectToReturn as? T
    }
    
    func update<T: Managed>(with json: JSONDictionary, on context: NSManagedObjectContext) -> T? {
        assertionFailure("The tags can't be updated")
        return self as? T
    }
}
