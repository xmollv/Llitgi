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
    
    private let dependecies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependecies = dependencies
    }
    
    func instantiate<T: ViewController>() -> T {
        let viewController = T(factory: self, dependencies: self.dependecies)
        return viewController
    }
    
    func instantiateListViewController(type: TypeOfList) -> ListViewController {
        return ListViewController(factory: self, dependencies: self.dependecies, type: type)
    }
}
