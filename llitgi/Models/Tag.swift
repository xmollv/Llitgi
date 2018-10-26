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
}

@objc(CoreDataTag)
final class CoreDataTag: NSManagedObject, Tag {
    
    //MARK: Private properties
    @NSManaged private var name_: String
    @NSManaged private var item_: [CoreDataItem]
    
    var name: String {
        get { return self.read(key: "name_")! }
        set { self.update(key: "name_", with: newValue) }
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
