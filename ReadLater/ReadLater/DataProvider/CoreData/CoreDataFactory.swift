//
//  CoreDataFactory.swift
//  ReadLater
//
//  Created by Xavi Moll on 27/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import Foundation
import CoreData

protocol CoreDataFactory: class {
    func build<T: Managed>(jsonArray: JSONArray) -> [T]
}

final class CoreDataFactoryImplementation: CoreDataFactory {
    
    let name: String
    let fileManager: FileManager
    
    init(name: String = "CoreDataModel", fileManager: FileManager = FileManager.default) {
        self.name = name
        self.fileManager = fileManager
    }
    
    private lazy var mainThreadContext: NSManagedObjectContext = {
        let context = self.storeContainer.viewContext
        context.automaticallyMergesChangesFromParent = true
        return context
    }()
    
    private lazy var context: NSManagedObjectContext = {
        let context = self.storeContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        return context
    }()
    
    private lazy var storeContainer: NSPersistentContainer = {
        let storeURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(name)
        Logger.log("Core Data path: \(storeURL.absoluteString)")
        let description = NSPersistentStoreDescription(url: storeURL)
        description.setOption(FileProtectionType.completeUnlessOpen.rawValue as NSString, forKey: NSPersistentStoreFileProtectionKey)
        
        let container = NSPersistentContainer(name: "CoreDataModel")
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                Logger.log("Unresolved error \(error), \(error.userInfo)", event: .error)
            }
        }
        return container
    }()
    
    func build<T: Managed>(jsonArray: JSONArray) -> [T] {
        let objects: [T] = jsonArray.flatMap { self.build(json: $0, in: self.context) }
        self.context.performAndWait {
            do {
                try self.context.save()
            } catch {
                Logger.log("Error trying to save the context: \(error)", event: .error)
            }
        }
        return objects
    }
    
    private func build<T: Managed>(json: JSONDictionary, in context: NSManagedObjectContext, shouldSave: Bool = false) -> T? {
        let object: T? = T.fetchOrCreate(with: json, in: context)
        guard let updatedObject: T = object?.update(with: json, on: context) else {
            //TODO: Delete the failed updated object
            return nil
        }
        return updatedObject
    }
}
