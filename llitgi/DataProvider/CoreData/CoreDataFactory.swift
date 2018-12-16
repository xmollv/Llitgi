//
//  CoreDataFactory.swift
//  llitgi
//
//  Created by Xavi Moll on 27/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import Foundation
import CoreData

protocol CoreDataFactory: class {
    func build<T: Managed>(jsonArray: JSONArray) -> [T]
    func badgeNotifier() -> CoreDataNotifier<CoreDataItem>
    func notifier(for: TypeOfList, matching: String?) -> CoreDataNotifier<CoreDataItem>
    func deleteAllModels()
}

final class CoreDataFactoryImplementation: CoreDataFactory {

    //MARK: Private properties
    private let name: String
    private let fileManager: FileManager
    private let storeContainer: NSPersistentContainer
    private let mainThreadContext: NSManagedObjectContext
    private let backgroundContext: NSManagedObjectContext
    
    //MARK:  Lifecycle
    init(name: String = "CoreDataModel", fileManager: FileManager = FileManager.default) {
        self.name = name
        self.fileManager = fileManager
        self.storeContainer = NSPersistentContainer(name: name)
        
        let storeURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(name)
        let description = NSPersistentStoreDescription(url: storeURL)
        self.storeContainer.persistentStoreDescriptions = [description]
        self.storeContainer.loadPersistentStores { (storeDescription, error) in
            if let _ = error {
                fatalError("Unable to load the persistent stores.")
            }
        }
        
        self.mainThreadContext = self.storeContainer.viewContext
        self.mainThreadContext.automaticallyMergesChangesFromParent = true
        
        self.backgroundContext = self.storeContainer.newBackgroundContext()
        self.backgroundContext.automaticallyMergesChangesFromParent = true
    }
    
    //MARK: Public methods
    func build<T: Managed>(jsonArray: JSONArray) -> [T] {
        var objects: [T] = []
        self.backgroundContext.performAndWait {
            objects = jsonArray.compactMap { self.build(json: $0, in: self.backgroundContext) }
        }
        self.saveBackgroundContext()
        return objects
    }
    
    func badgeNotifier() -> CoreDataNotifier<CoreDataItem> {
        let request = NSFetchRequest<CoreDataItem>(entityName: String(describing: CoreDataItem.self))
        request.predicate = NSPredicate(format: "status_ == '0'")
        request.sortDescriptors = [NSSortDescriptor(key: "id_", ascending: false)]
        let frc = NSFetchedResultsController(fetchRequest: request,
                                             managedObjectContext: self.mainThreadContext,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        return CoreDataNotifier(fetchResultController: frc)
    }
    
    func notifier(for type: TypeOfList, matching query: String?) -> CoreDataNotifier<CoreDataItem> {
        let request = NSFetchRequest<CoreDataItem>(entityName: String(describing: CoreDataItem.self))
        request.sortDescriptors = [NSSortDescriptor(key: "timeAdded_", ascending: false)]
        
        // Store the predicates to be able to create an NSCompoundPredicate at the end
        var predicates: [NSPredicate] = []
        
        if let query = query {
            // We use this for the search. Otherwise, the FRC returns every item matching the type
            let searchPredicate = NSPredicate(format: "(title_ CONTAINS[cd] %@ OR url_ CONTAINS[cd] %@) AND status_ != '2'", query, query)
            predicates.append(searchPredicate)
        }
        
        let typePredicate: NSPredicate
        switch type {
        case .all:
            typePredicate = NSPredicate(format: "status_ != '2'")
        case .myList:
            typePredicate = NSPredicate(format: "status_ == '0'")
        case .favorites:
            typePredicate = NSPredicate(format: "isFavorite_ == true")
        case .archive:
            typePredicate = NSPredicate(format: "status_ == '1'")
        }
        
        predicates.append(typePredicate)
        
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates.compactMap { $0 })
        
        let frc = NSFetchedResultsController(fetchRequest: request,
                                             managedObjectContext: self.mainThreadContext,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        return CoreDataNotifier(fetchResultController: frc)
    }
    
    func deleteAllModels() {
        self.storeContainer.managedObjectModel.entities.compactMap {
            guard let name = $0.name else {
                Logger.log("This entity doesn't have a name: \($0)")
                return nil
            }
            let fetch:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: name)
            return fetch
            }.forEach { self.deleteResults(of: $0) }
        
        self.saveBackgroundContext()
    }
    
    //MARK: Private methods
    private func saveBackgroundContext() {
        self.backgroundContext.performAndWait {
            do {
                try self.backgroundContext.save()
            } catch {
                Logger.log(error.localizedDescription, event: .error)
            }
        }
    }
    
    private func build<T: Managed>(json: JSONDictionary, in context: NSManagedObjectContext) -> T? {
        let object: T? = T.fetchOrCreate(with: json, on: context)
        guard let updatedObject: T = object?.update(with: json, on: context) else {
            self.delete(object, in: context)
            return nil
        }
        if let item = updatedObject as? Item, item.status == .deleted {
            self.delete(updatedObject, in: context)
            return nil
        }
        
        return updatedObject
    }
    
    private func delete<T: Managed>(_ object: T?, in context: NSManagedObjectContext) {
        guard let object = object else { return }
        context.performAndWait {
            context.delete(object)
        }
    }
    
    private func deleteResults(of fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        self.backgroundContext.performAndWait {
            do {
                try self.backgroundContext.fetch(fetchRequest).forEach {
                    guard let managedObject = $0 as? NSManagedObject else {
                        Logger.log("The object was not a NSManagedObject: \($0)")
                        return
                    }
                    backgroundContext.delete(managedObject)
                }
            } catch {
                Logger.log(error.localizedDescription, event: .error)
            }
        }
    }
}
