//
//  PocketEndpoint.swift
//  llitgi
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
    case sync(last: TimeInterval?)
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
        case .sync:
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
        // Response is a JSON object
        case .requestToken, .authorize, .modify, .add:
            return { (json: Any?) in
                guard let elements = json as? JSONDictionary else { return nil }
                return [elements]
            }
        // Response is an array of JSON objects
        case .sync:
            return { (json: Any?) in
                guard let dict = json as? JSONDictionary else { return nil }
                let listAsDict = (dict["list"] as? JSONDictionary) ?? [:]
                let list = listAsDict.values.flatMap { $0 as? JSONDictionary }
                return list
            }
        }
    }
}
