//
//  Managed.swift
//  ReadLater
//
//  Created by Xavi Moll on 28/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import Foundation
import CoreData

typealias Managed = NSManagedObject & CoreDataManaged

protocol CoreDataManaged: class {
    var id: String { get set }
    var status: String { get }
    func update<T: Managed>(with: JSONDictionary, on: NSManagedObjectContext) -> T?
}
