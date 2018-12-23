//
//  PocketAPIModification.swift
//  llitgi
//
//  Created by Xavi Moll on 26/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import Foundation

struct ItemModification {
    enum TypeOfAction {
        case add
        case archive
        case readd //unarchive
        case favorite
        case unfavorite
        case delete
        case replaceTags(with: [String])
        
        var stringValue: String {
            switch self {
            case .add: return "add"
            case .archive: return "archive"
            case .readd: return "readd"
            case .favorite: return "favorite"
            case .unfavorite: return "unfavorite"
            case .delete: return "delete"
            case .replaceTags: return "tags_replace"
            }
        }
    }
    
    let action: TypeOfAction
    let id: String
    
    var wrappedAsDict: [String : String] {
        var dict = ["action" : self.action.stringValue,
                    "item_id" : self.id]
        switch self.action {
        case .replaceTags(let tags):
            dict["tags"] = tags.joined(separator: ",")
        default: break
        }
        return dict
    }
}
