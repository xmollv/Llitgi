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
final class CoreDataTag: NSManagedObject, Tag {
    
    //MARK: Private properties
    @NSManaged private var name_: String
    @NSManaged private var items_: [CoreDataItem]
    
    var name: String {
        get { return self.read(key: "name_")! }
        set { self.update(key: "name_", with: newValue) }
    }
    var items: [Item] {
        if let nssetItems: NSSet = self.read(key: "items_") {
            return (nssetItems.allObjects as? [CoreDataItem])?.sorted { $0.timeUpdated < $1.timeUpdated } ?? []
        } else {
            return []
        }
    }
    
    static func create(with name: String, in context: NSManagedObjectContext) -> CoreDataTag? {
        guard let entity = NSEntityDescription.entity(forEntityName: String(describing: CoreDataTag.self), in: context) else {
            Logger.log("Invalid Core Data configuration", event: .error)
            return nil
        }
        var object: CoreDataTag?
        context.performAndWait {
            object = CoreDataTag.init(entity: entity, insertInto: context)
            object?.name = name
        }
        return object
    }
}
