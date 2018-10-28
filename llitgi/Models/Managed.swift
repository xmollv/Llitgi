//
//  Managed.swift
//  llitgi
//
//  Created by Xavi Moll on 28/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import Foundation
import CoreData

typealias Managed = NSManagedObject & CoreDataManaged

protocol CoreDataManaged: class {
    static func fetchOrCreate<T: Managed>(with: JSONDictionary, on: NSManagedObjectContext) -> T?
    func update<T: Managed>(with: JSONDictionary, on: NSManagedObjectContext) -> T?
}
