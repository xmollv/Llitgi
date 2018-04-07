//
//  CoreDataFactory.swift
//  llitgi
//
//  Created by Xavi Moll on 27/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import Foundation
import CoreData
import CoreSpotlight
import MobileCoreServices

protocol CoreDataFactory: class {
    func build<T: Managed>(jsonArray: JSONArray) -> [T]
    func notifier(for: TypeOfList) -> CoreDataNotifier
    func search(_: String) -> [CoreDataItem]
    func hasItem(identifiedBy id: String) -> CoreDataItem?
    func deleteAllModels()
    func numberOfItems(on: TypeOfList) -> Int
}

final class CoreDataFactoryImplementation: CoreDataFactory {

    //MARK: Private properties
    private let name: String
    private let fileManager: FileManager
    
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
    
    //MARK:  Lifecycle
    init(name: String = "CoreDataModel", fileManager: FileManager = FileManager.default) {
        self.name = name
        self.fileManager = fileManager
    }
    
    //MARK: Public methods
    func build<T: Managed>(jsonArray: JSONArray) -> [T] {
        let objects: [T] = jsonArray.compactMap { self.build(json: $0, in: self.context) }
        self.saveBackgroundContext()
        return objects
    }
    
    func notifier(for type: TypeOfList) -> CoreDataNotifier {
        let request = NSFetchRequest<CoreDataItem>(entityName: String(describing: CoreDataItem.self))
        
        var predicate: NSPredicate?
        switch type {
        case .myList:
            predicate = NSPredicate(format: "status_ == '0'")
            let addedTime = NSSortDescriptor(key: "timeAdded_", ascending: false)
            let id = NSSortDescriptor(key: "id_", ascending: false)
            request.sortDescriptors = [addedTime, id]
        case .favorites:
            predicate = NSPredicate(format: "isFavorite_ == true")
            let timeUpdated = NSSortDescriptor(key: "timeUpdated_", ascending: false)
            let addedTime = NSSortDescriptor(key: "timeAdded_", ascending: false)
            request.sortDescriptors = [timeUpdated, addedTime]
        case .archive:
            predicate = NSPredicate(format: "status_ == '1'")
            let timeUpdated = NSSortDescriptor(key: "timeUpdated_", ascending: false)
            let addedTime = NSSortDescriptor(key: "timeAdded_", ascending: false)
            request.sortDescriptors = [timeUpdated, addedTime]
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
        request.predicate = NSPredicate(format: "(title_ CONTAINS[c] %@ OR url_ CONTAINS[c] %@) AND status_ != '2'", text, text)
        request.sortDescriptors = [NSSortDescriptor(key: "timeAdded_", ascending: false, selector: #selector(NSString.caseInsensitiveCompare(_:)))]
        
        var results: [CoreDataItem] = []
        self.context.performAndWait {
            do {
                results = try self.context.fetch(request)
            } catch {
                Logger.log(error.localizedDescription, event: .error)
            }
        }
        return results
    }
    
    func hasItem(identifiedBy id: String) -> CoreDataItem?  {
        let request = NSFetchRequest<CoreDataItem>(entityName: String(describing: CoreDataItem.self))
        request.predicate = NSPredicate(format: "id_ == %@ ", id)
        var result: CoreDataItem?
        self.context.performAndWait {
            do {
                result = try self.context.fetch(request).first
            } catch {
                Logger.log(error.localizedDescription, event: .error)
            }
        }
        return result
    }
    
    func deleteAllModels() {
        CSSearchableIndex.default().deleteAllSearchableItems { (error) in
            guard let error = error else { return }
            Logger.log(error.localizedDescription, event: .error)
        }
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
    
    func numberOfItems(on list: TypeOfList) -> Int {
        let request = NSFetchRequest<CoreDataItem>(entityName: String(describing: CoreDataItem.self))
        
        var predicate: NSPredicate?
        switch list {
        case .myList:
            predicate = NSPredicate(format: "status_ == '0'")
        case .favorites:
            predicate = NSPredicate(format: "isFavorite_ == true")
        case .archive:
            predicate = NSPredicate(format: "status_ == '1'")
        }
        request.predicate = predicate
        
        var count: Int = 0
        self.context.performAndWait {
            do {
                count = try self.context.count(for: request)
            } catch {
                Logger.log(error.localizedDescription, event: .error)
            }
        }
        
        return count
    }
    
    //MARK: Private methods
    private func saveBackgroundContext() {
        self.context.performAndWait {
            do {
                try self.context.save()
            } catch {
                Logger.log(error.localizedDescription, event: .error)
            }
        }
    }
    
    private func build<T: Managed>(json: JSONDictionary, in context: NSManagedObjectContext) -> T? {
        let object: T? = T.fetchOrCreate(with: json, in: context)
        guard let updatedObject: T = object?.update(with: json, on: context) else {
            self.delete(object, in: context)
            return nil
        }
        if let item = updatedObject as? Item, item.status == "2" {
            self.delete(updatedObject, in: context)
            return nil
        }
        
        if let item = updatedObject as? CoreDataItem {
            self.indexInSpotlight(item: item)
        }
        
        return updatedObject
    }
    
    private func delete<T: Managed>(_ object: T?, in context: NSManagedObjectContext) {
        guard let object = object else { return }
        Logger.log("Maked \(object.id) to be deleted.", event: .warning)
        if let item = object as? CoreDataItem {
            self.deindexItem(id: item.id)
        }
        context.performAndWait {
            context.delete(object)
        }
    }
    
    private func indexInSpotlight(item: CoreDataItem) {
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
        attributeSet.title = item.title
        attributeSet.contentDescription = item.url.absoluteString
        
        let item = CSSearchableItem(uniqueIdentifier: item.id, domainIdentifier: "com.xmollv.llitgi", attributeSet: attributeSet)
        CSSearchableIndex.default().indexSearchableItems([item]) { error in
            guard let error = error else { return }
            Logger.log(error.localizedDescription, event: .error)
        }
    }
    
    private func deindexItem(id: String) {
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [id]) { error in
            guard let error = error else { return }
            Logger.log(error.localizedDescription, event: .error)
        }
    }
    
    private func deleteResults(of fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        self.context.performAndWait {
            do {
                try self.context.fetch(fetchRequest).forEach {
                    guard let managedObject = $0 as? NSManagedObject else {
                        Logger.log("The object was not a NSManagedObject: \($0)")
                        return
                    }
                    context.delete(managedObject)
                }
            } catch {
                Logger.log(error.localizedDescription, event: .error)
            }
        }
    }
}
