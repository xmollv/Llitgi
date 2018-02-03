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
    func build<T: Managed>(jsonArray: JSONArray, for: TypeOfList) -> [T]
    func notifier(for: TypeOfList) -> CoreDataNotifier
    func search(_: String) -> [CoreDataItem]
    func deleteAllModels()
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
    
    func build<T: Managed>(jsonArray: JSONArray, for list: TypeOfList) -> [T] {
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
    
    private func build<T: Managed>(json: JSONDictionary, in context: NSManagedObjectContext) -> T? {
        let object: T? = T.fetchOrCreate(with: json, in: context)
        guard let updatedObject: T = object?.update(with: json, on: context) else {
            self.delete(object, in: context)
            return nil
        }
        if updatedObject.status == "2" {
            self.delete(updatedObject, in: context)
            return nil
        }
        return updatedObject
    }
    
    private func delete<T: Managed>(_ object: T?, in context: NSManagedObjectContext) {
        guard let object = object else { return }
        Logger.log("Maked \(object.id) to be deleted.", event: .warning)
        context.performAndWait {
            context.delete(object)
        }
    }
    
    func notifier(for type: TypeOfList) -> CoreDataNotifier {
        let request = NSFetchRequest<CoreDataItem>(entityName: String(describing: CoreDataItem.self))
        //TODO: Change for the edit time
        request.sortDescriptors = [NSSortDescriptor(key: "timeAdded_", ascending: false)]
        
        var predicate: NSPredicate?
        switch type {
        case .myList:
            predicate = NSPredicate(format: "status_ == '0'")
        case .favorites:
            predicate = NSPredicate(format: "isFavorite_ == true")
        case .archive:
            predicate = NSPredicate(format: "status_ == '1'")
        }
        request.predicate = predicate
        
        let frc = NSFetchedResultsController(fetchRequest: request,
                                             managedObjectContext: self.mainThreadContext,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        return CoreDataNotifier(fetchResultController: frc)
    }
    
    func search(_ text: String) -> [CoreDataItem] {
        let request = NSFetchRequest<CoreDataItem>(entityName: String(describing: CoreDataItem.self))
        request.predicate = NSPredicate(format: "title_ CONTAINS[c] %@ OR url_ CONTAINS[c] %@", text, text)
        //TODO: Change for the edit time
        request.sortDescriptors = [NSSortDescriptor(key: "timeAdded_", ascending: false, selector: #selector(NSString.caseInsensitiveCompare(_:)))]
        do {
            let results = try self.context.fetch(request)
            return results
        } catch {
            Logger.log("Error trying to fetch when searching: \(error)", event: .error)
            return []
        }
    }
    
    func deleteAllModels() {
        self.storeContainer.managedObjectModel.entities.flatMap {
            guard let name = $0.name else {
                Logger.log("This entity doesn't have a name: \($0)")
                return nil
            }
            let fetch:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: name)
            return fetch
            }.forEach {
                self.delete(fetch: $0)
        }

        self.context.performAndWait {
            do {
                try self.context.save()
            } catch {
                Logger.log("Error trying to save the context: \(error)", event: .error)
            }
        }
    }
    
    private func delete(fetch: NSFetchRequest<NSFetchRequestResult>) {
        do {
            try self.context.fetch(fetch).forEach {
                guard let managedObject = $0 as? NSManagedObject else {
                    Logger.log("The object was not a NSManagedObject: \($0)")
                    return
                }
                context.delete(managedObject)
            }
        } catch {
            Logger.log("Error on deleting entity: \(fetch.entity?.name ?? ""): \(error.localizedDescription)", event: .error)
        }
    }
}
