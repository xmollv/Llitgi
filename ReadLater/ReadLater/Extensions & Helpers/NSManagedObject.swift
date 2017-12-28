//
//  NSManagedObject.swift
//  ReadLater
//
//  Created by Xavi Moll on 28/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {

    static func fetchOrCreate<T: Managed>(with json: JSONDictionary, in context: NSManagedObjectContext) -> T? {
        guard let id = json["item_id"] as? String else { return nil }
        if let fetchedElement: T = T.fetch(with: id, in: context) {
            return fetchedElement
        } else {
            return T.create(with: id, in: context)
        }
    }
    
    fileprivate static func fetch<T: Managed>(with id: String, in context: NSManagedObjectContext) -> T? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: T.self))
        let predicate = NSPredicate(format: "id_ == %@", argumentArray: [id])
        request.predicate = predicate
        //TODO: Add sort descriptors
        var fetchedElement: T?
        context.performAndWait {
            do {
                let fetchedElements = try context.fetch(request) as? [T]
                fetchedElement = fetchedElements?.first
            } catch {
                Logger.log("Error trying to perform a fetch: \(error)", event: .error)
            }
        }
        return fetchedElement
    }
    
    fileprivate static func create<T: Managed>(with id: String, in context: NSManagedObjectContext) -> T? {
        guard let entity = NSEntityDescription.entity(forEntityName: String(describing: T.self), in: context) else {
            fatalError("Invalid Core Data configuration")
        }
        let object = T.init(entity: entity, insertInto: context)
        object.id = id
        return object
    }
}
