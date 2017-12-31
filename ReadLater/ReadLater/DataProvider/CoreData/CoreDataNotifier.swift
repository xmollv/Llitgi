//
//  CoreDataNotifier.swift
//  ReadLater
//
//  Created by Xavi Moll on 27/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import Foundation

import UIKit
import CoreData.NSFetchedResultsController

class CoreDataNotifier: NSObject {

    enum PersistanceChange {
        case update(indexPath: IndexPath)
        case insert(indexPath: IndexPath)
        case delete(indexPath: IndexPath)
        case move(from: IndexPath, to: IndexPath)
    }
    
    typealias PersistanceWillChange = () -> Void
    typealias PersistanceDidChange = () -> Void
    typealias PersistanceChangeObject = (PersistanceChange) -> Void
    
    //MARK:- Private properties
    private let fetchResultController: NSFetchedResultsController<CoreDataItem>
    private var willChangeClosure: PersistanceWillChange?
    private var didChangeClosure: PersistanceDidChange?
    private var changeObjectClosure: PersistanceChangeObject?
    
    //MARK:- Lifecycle
    init(fetchResultController: NSFetchedResultsController<CoreDataItem>) {
        self.fetchResultController = fetchResultController
        super.init()
        self.fetchResultController.delegate = self
    }
    
    //MARK:- Public methods
    func startNotifying() -> CoreDataNotifier {
        do {
            try self.fetchResultController.performFetch()
        } catch {
            Logger.log(error.localizedDescription, event: .error)
        }
        return self
    }
    
    func onBeginChanging(_ closure: @escaping PersistanceWillChange) -> CoreDataNotifier {
        self.willChangeClosure = closure
        return self
    }
    
    func onObjectChanged(_ closure: @escaping PersistanceChangeObject) -> CoreDataNotifier {
        self.changeObjectClosure = closure
        return self
    }
    
    func onFinishChanging(_ closure: @escaping PersistanceDidChange) -> CoreDataNotifier {
        self.didChangeClosure = closure
        return self
    }
    
    //MARK:- Public helper methods
    func numberOfObjects(on section: Int) -> Int {
        let numberOfSections = self.fetchResultController.sections?.count ?? 0
        guard section < numberOfSections else { return 0 }
        guard let section = self.fetchResultController.sections?[section] else { return 0 }
        return section.objects?.count ?? 0
    }
    
    func object<T>(at indexPath: IndexPath) -> T? {
        return self.fetchResultController.object(at: indexPath) as? T
    }
}

//MARK:- NSFetchedResultsControllerDelegate
extension CoreDataNotifier: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.willChangeClosure?()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        let change: PersistanceChange
        
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            change = .insert(indexPath: newIndexPath)
        case .move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
            change = .move(from: indexPath, to: newIndexPath)
        case .update:
            guard let indexPath = indexPath else { return }
            change = .update(indexPath: indexPath)
        case .delete:
            guard let indexPath = indexPath else { return }
            change = .delete(indexPath: indexPath)
        }
        
        self.changeObjectClosure?(change)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.didChangeClosure?()
    }
}
