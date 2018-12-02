//
//  TypeOfList.swift
//  llitgi
//
//  Created by Xavi Moll on 02/12/2018.
//  Copyright © 2018 xmollv. All rights reserved.
//

import Foundation

enum TypeOfList: Int {
    case all = 0
    case myList = 1
    case favorites = 2
    case archive = 3
    
    init(selectedScope: Int) {
        switch selectedScope {
        case 0: self = .all
        case 1: self = .myList
        case 2: self = .favorites
        case 3: self = .archive
        default: fatalError("You've fucked up.")
        }
    }
    
    var position: Int {
        return self.rawValue
    }
}
