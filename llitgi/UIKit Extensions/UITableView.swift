//
//  UITableView + Extensions.swift
//  llitgi
//
//  Created by Xavi Moll on 17/02/2018.
//  Copyright © 2018 xmollv. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    
    /// This method deselects a row from a UITableView alognside the UIViewControllerTransitionCoordinator from
    /// the UIViewController that presented the UITableView. If we can't find the UIViewControllerTransitionCoordinator,
    /// we just deselect the row. Specify the flag `animated` to use animations or not.
    ///
    /// **Source:** [GitHub Gist](https://gist.github.com/smileyborg/ec4812c146f575cd006d98d681108ba8)
    func deselectRow(with transitionCoordinator: UIViewControllerTransitionCoordinator?, animated: Bool) {
        guard let selectedIndexPath = self.indexPathForSelectedRow else { return }
        guard let coordinator = transitionCoordinator else {
            self.deselectRow(at: selectedIndexPath, animated: animated)
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            self.deselectRow(at: selectedIndexPath, animated: true)
        }, completion: { context in
            if context.isCancelled {
                self.selectRow(at: selectedIndexPath, animated: false, scrollPosition: .none)
            }
        })
    }
}
