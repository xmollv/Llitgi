//
//  CoreDataNotifier.swift
//  llitgi
//
//  Created by Xavi Moll on 27/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import CoreData

protocol CoreDataNotifierDelegate: class {
    func willChangeContent()
    func didChangeSection(_ change: CoreDataNotifierSectionChange)
    func didChangeObject(_ change: CoreDataNotifierObjectChange)
    func didChangeContent()
    func startNotifyingFailed(with: Error)
}

enum CoreDataNotifierSectionChange {
    case insert(sectionIndex: Int)
    case delete(sectionIndex: Int)
}

enum CoreDataNotifierObjectChange {
    case update(indexPath: IndexPath)
    case insert(indexPath: IndexPath)
    case delete(indexPath: IndexPath)
    case move(from: IndexPath, to: IndexPath)
}

class CoreDataNotifier<T: NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate {
    
    //MARK:- Private properties
    private let fetchResultController: NSFetchedResultsController<T>
    
    //MARK: Public properties
    weak var delegate: CoreDataNotifierDelegate? = nil
    
    //MARK:- Lifecycle
    init(fetchResultController: NSFetchedResultsController<T>) {
        self.fetchResultController = fetchResultController
        super.init()
    }
    
    //MARK:- Public methods
    func startNotifying() {
        self.fetchResultController.delegate = self
        do {
            try self.fetchResultController.performFetch()
        } catch {
            self.delegate?.startNotifyingFailed(with: error)
        }
    }
    
    func stopNotifying() {
        self.fetchResultController.delegate = nil
    }
    
    func element(at indexPath: IndexPath) -> T {
        return self.fetchResultController.object(at: indexPath)
    }
    
    func numberOfSections() -> Int {
        guard let numberOfSections = self.fetchResultController.sections?.count else { return 0 }
        return numberOfSections
    }
    
    func numberOfElements(inSection section: Int) -> Int {
        let numberOfSections = self.fetchResultController.sections?.count ?? 0
        guard section < numberOfSections else { return 0 }
        guard let section = self.fetchResultController.sections?[section] else { return 0 }
        return section.objects?.count ?? 0
    }
    
    //MARK:- NSFetchedResultsControllerDelegate
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        assert(self.delegate != nil, "The delegate for the CoreDataNotifier is nil.")
        self.delegate?.willChangeContent()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        assert(self.delegate != nil, "The delegate for the CoreDataNotifier is nil.")
        
        switch type {
        case .insert:
            self.delegate?.didChangeSection(.insert(sectionIndex: sectionIndex))
        case .delete:
            self.delegate?.didChangeSection(.delete(sectionIndex: sectionIndex))
        default:
            assertionFailure("This should never happen based on the docs")
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        assert(self.delegate != nil, "The delegate for the CoreDataNotifier is nil.")
        
        let change: CoreDataNotifierObjectChange
        
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
        @unknown default:
            fatalError("Unhandled change")
        }
        
        self.delegate?.didChangeObject(change)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        assert(self.delegate != nil, "The delegate for the CoreDataNotifier is nil.")
        self.delegate?.didChangeContent()
    }
}
