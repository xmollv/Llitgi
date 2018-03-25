//
//  PocketAPIModification.swift
//  llitgi
//
//  Created by Xavi Moll on 26/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import Foundation

struct ItemModification {
    enum TypeOfAction: String {
        case add
        case archive
        case readd //unarchive
        case favorite
        case unfavorite
        case delete
    }
    
    let action: TypeOfAction
    let id: String
    
    var wrappedAsDict: [String : String] {
        return ["action" : self.action.rawValue,
                "item_id" : self.id]
    }
}
