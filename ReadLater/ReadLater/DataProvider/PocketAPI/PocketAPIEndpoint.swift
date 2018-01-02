//
//  PocketEndpoint.swift
//  ReadLater
//
//  Created by Xavi Moll on 24/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import Foundation

enum PocketAPIEndpoint {
    // Authorization endpoints
    case requestToken
    case authorize
    
    // Already authorized endpoints
    case getFavorites
    case getList
    case getArchive
    
    case modify(ItemModification)
    
    case add(URL)
    
    /// Returns the full URL to perform the request
    var url: URL {
        let baseUrl = URL(string: "https://getpocket.com/v3")!
        switch self {
        case .requestToken:
            return baseUrl.appendingPathComponent("oauth/request")
        case .authorize:
            return baseUrl.appendingPathComponent("oauth/authorize")
        case .getFavorites, .getList, .getArchive:
            return baseUrl.appendingPathComponent("get")
        case .modify:
            return baseUrl.appendingPathComponent("send")
        case .add:
            return baseUrl.appendingPathComponent("add")
        }
    }

    /// Transforms the raw JSON(Any) into a JSONArray 
    var parser: (Any?) -> JSONArray? {
        switch self {
        case .requestToken, .authorize:
            return { (json: Any?) in
                guard let elements = json as? JSONDictionary else { return nil }
                return [elements]
            }
        case .getFavorites, .getList, .getArchive:
            return { (json: Any?) in
                guard let dict = json as? JSONDictionary else { return nil }
                let listAsDict = (dict["list"] as? JSONDictionary) ?? [:]
                let list = listAsDict.values.flatMap { $0 as? JSONDictionary }
                return list
            }
        case .modify, .add:
            return { (json: Any?) in
                guard let dict = json as? JSONDictionary else { return nil }
                return [dict]
            }
        }
    }
}
