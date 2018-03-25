//
//  ViewControllerFactory.swift
//  llitgi
//
//  Created by Xavi Moll on 24/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import Foundation
import UIKit

final class ViewControllerFactory {
    
    //MARK: Private properties
    private let dependecies: Dependencies
    
    //MARK: Lifecycle
    init(dependencies: Dependencies) {
        self.dependecies = dependencies
    }
    
    //MARK: Public methods
    func instantiate<T: ViewController>() -> T {
        let viewController = T(factory: self, dependencies: self.dependecies)
        return viewController
    }
    
    func instantiate(for type: TypeOfList) -> ListViewController {
        return ListViewController(factory: self, dependencies: self.dependecies, type: type)
    }
}
