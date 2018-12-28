//
//  CoreDataNotifier.swift
//  llitgi
//
//  Created by Xavi Moll on 27/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol CoreDataNotifierDelegate: class {
    func willChangeContent()
    func didChangeContent(_ change: CoreDataNotifierChange)
    func endChangingContent()
    func startNotifyingFailed(with: Error)
}

enum CoreDataNotifierChange {
    case update(indexPath: IndexPath)
    case insert(indexPath: IndexPath)
    case delete(indexPath: IndexPath)
    case move(from: IndexPath, to: IndexPath)
    
    var description: String {
        switch self {
        case .update(let indexPath): return "Update \(indexPath)"
        case .insert(let indexPath): return "Insert \(indexPath)"
        case .delete(let indexPath): return "Delete \(indexPath)"
        case .move(let from, let to): return "Move \(from) \(to)"
        }
    }
}

class CoreDataNotifier<T: NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate {
    
    //MARK:- Private properties
    private let fetchResultController: NSFetchedResultsController<T>
    
    //MARK: Public properties
    weak var delegate: CoreDataNotifierDelegate? = nil
    var sections: Int {
        return self.fetchResultController.sections?.count ?? 0
    }
    
    //MARK:- Lifecycle
    init(fetchResultController: NSFetchedResultsController<T>) {
        self.fetchResultController = fetchResultController
        super.init()
        self.fetchResultController.delegate = self
    }
    
    //MARK:- Public methods
    func startNotifying() {
        assert(self.delegate != nil, "The delegate for the CoreDataNotifier is nil.")
        do {
            try self.fetchResultController.performFetch()
        } catch {
            assertionFailure(error.localizedDescription)
            self.delegate?.startNotifyingFailed(with: error)
        }
    }
    
    func numberOfElements(inSection section: Int) -> Int {
        assert(self.delegate != nil, "The delegate for the CoreDataNotifier is nil.")
        let numberOfSections = self.fetchResultController.sections?.count ?? 0
        guard section < numberOfSections else {
            assertionFailure("Section is lower than the number of sectionsof the FRC")
            return 0
        }
        guard let section = self.fetchResultController.sections?[section] else {
            assertionFailure("Unable to grab the section from the FRC sections")
            return 0
        }
        return section.objects?.count ?? 0
    }
    
    func element(at indexPath: IndexPath) -> T {
        assert(self.delegate != nil, "The delegate for the CoreDataNotifier is nil.")
        return self.fetchResultController.object(at: indexPath)
    }
    
    //MARK:- NSFetchedResultsControllerDelegate
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        assert(self.delegate != nil, "The delegate for the CoreDataNotifier is nil.")
        self.delegate?.willChangeContent()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        assert(self.delegate != nil, "The delegate for the CoreDataNotifier is nil.")
        
        let change: CoreDataNotifierChange
        
        switch type {
        case .update:
            guard let indexPath = indexPath else {
                assertionFailure()
                return
            }
            change = .update(indexPath: indexPath)
        case .insert:
            guard let newIndexPath = newIndexPath else {
                assertionFailure()
                return
            }
            change = .insert(indexPath: newIndexPath)
        case .move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else {
                assertionFailure()
                return
            }
            change = .move(from: indexPath, to: newIndexPath)
        case .delete:
            guard let indexPath = indexPath else {
                assertionFailure()
                return
            }
            change = .delete(indexPath: indexPath)
        }
        
        self.delegate?.didChangeContent(change)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        assert(self.delegate != nil, "The delegate for the CoreDataNotifier is nil.")
        self.delegate?.endChangingContent()
    }
}
