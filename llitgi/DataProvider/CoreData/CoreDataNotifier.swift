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
    func startNotifyingFailed(with error: Error)
}

enum CoreDataNotifierChange {
    case update(indexPath: IndexPath)
    case insert(indexPath: IndexPath)
    case delete(indexPath: IndexPath)
    case move(from: IndexPath, to: IndexPath)
}

class CoreDataNotifier: NSObject {
    
    //MARK:- Private properties
    private let fetchResultController: NSFetchedResultsController<CoreDataItem>
    
    //MARK: Public properties
    var delegate: CoreDataNotifierDelegate? = nil
    
    //MARK:- Lifecycle
    init(fetchResultController: NSFetchedResultsController<CoreDataItem>) {
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
            Logger.log(error.localizedDescription, event: .error)
            self.delegate?.startNotifyingFailed(with: error)
        }
    }
    
    //MARK:- Public helper methods
    func numberOfObjects(on section: Int) -> Int {
        assert(self.delegate != nil, "The delegate for the CoreDataNotifier is nil.")
        let numberOfSections = self.fetchResultController.sections?.count ?? 0
        guard section < numberOfSections else {
            Logger.log("Section is smaller than the number of sectionsof the FRC", event: .error)
            return 0
        }
        guard let section = self.fetchResultController.sections?[section] else {
            Logger.log("Unable to grab the section from the FRC sections", event: .error)
            return 0
        }
        return section.objects?.count ?? 0
    }
    
    func object<T>(at indexPath: IndexPath) -> T? {
        assert(self.delegate != nil, "The delegate for the CoreDataNotifier is nil.")
        return self.fetchResultController.object(at: indexPath) as? T
    }
}

//MARK:- NSFetchedResultsControllerDelegate
extension CoreDataNotifier: NSFetchedResultsControllerDelegate {
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
