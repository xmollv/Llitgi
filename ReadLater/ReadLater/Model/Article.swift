//
//  Article.swift
//  ReadLater
//
//  Created by Xavi Moll on 25/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import Foundation

protocol Article: JSONInitiable {
    var id: String { get }
    var title: String { get }
    var url: URL { get }
}

struct ArticleImplementation: Article {
    
    let id: String
    let title: String
    let url: URL
    
    init?(dict: JSONDictionary) {
        guard let id = dict["item_id"] as? String else { return nil }
        guard let urlAsString = (dict["resolved_url"] as? String) ?? (dict["given_url"] as? String) else { return nil }
        guard let url = URL(string: urlAsString) else { return nil }
        
        self.id = id
        self.title = (dict["resolved_title"] as? String) ?? (dict["given_title"] as? String) ?? NSLocalizedString("Unknown", comment: "")
        self.url = url
    }
}
