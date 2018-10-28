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
            return (nssetItems.allObjects as? [CoreDataItem])?.sorted { $0.timeAdded < $1.timeAdded } ?? []
        } else {
            return []
        }
    }
    
    static func create(with name: String, in context: NSManagedObjectContext) -> CoreDataTag? {
        if let fetchedObject = self.fetch(with: name, in: context) {
            print("Fetched: \(name)")
            return fetchedObject
        } else {
            print("Created: \(name)")
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
    
    fileprivate static func fetch(with id: String, in context: NSManagedObjectContext) -> CoreDataTag? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: CoreDataTag.self))
        request.predicate = NSPredicate(format: "name_ == %@", argumentArray: [id])
        var fetchedElement: CoreDataTag?
        context.performAndWait {
            do {
                let fetchedElements = try context.fetch(request) as? [CoreDataTag]
                fetchedElement = fetchedElements?.first
            } catch {
                Logger.log(error.localizedDescription, event: .error)
            }
        }
        return fetchedElement
    }
}
