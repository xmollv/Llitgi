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
    
    func saveBackgroundContext() {
        self.context.performAndWait {
            do {
                try self.context.save()
            } catch {
                Logger.log("Error trying to save the context: \(error.localizedDescription)", event: .error)
            }
        }
    }
    
    func build<T: Managed>(jsonArray: JSONArray) -> [T] {
        let objects: [T] = jsonArray.flatMap { self.build(json: $0, in: self.context) }
        self.saveBackgroundContext()
        return objects
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
            
        }
    }
    
    private func deindexItem(id: String) {
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: []) { error in
            guard let error = error else { return }
            Logger.log("Error deindexing: \(error.localizedDescription)", event: .error)
        }
    }
    
    func notifier(for type: TypeOfList) -> CoreDataNotifier {
        let request = NSFetchRequest<CoreDataItem>(entityName: String(describing: CoreDataItem.self))
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
        request.sortDescriptors = [NSSortDescriptor(key: "timeAdded_", ascending: false, selector: #selector(NSString.caseInsensitiveCompare(_:)))]
        
        var results: [CoreDataItem] = []
        self.context.performAndWait {
            do {
                results = try self.context.fetch(request)
            } catch {
                Logger.log("Error trying to fetch when searching: \(error)", event: .error)
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
                Logger.log("Error trying to fetch when searching: \(error)", event: .error)
            }
        }
        return result
    }
    
    func deleteAllModels() {
        CSSearchableIndex.default().deleteAllSearchableItems { (error) in
            guard let error = error else { return }
            Logger.log("Error deindexing everything: \(error.localizedDescription)", event: .error)
        }
        self.storeContainer.managedObjectModel.entities.flatMap {
            guard let name = $0.name else {
                Logger.log("This entity doesn't have a name: \($0)")
                return nil
            }
            let fetch:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: name)
            return fetch
        }.forEach { self.deleteResults(of: $0) }

        self.saveBackgroundContext()
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
                Logger.log("Error on deleting entity: \(fetchRequest.entity?.name ?? ""): \(error.localizedDescription)", event: .error)
            }
        }
    }
}
