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
    case getList
    
    /// Returns the full URL to perform the request
    var url: URL {
        let baseUrl = URL(string: "https://getpocket.com/v3")!
        switch self {
        case .requestToken:
            return baseUrl.appendingPathComponent("oauth/request")
        case .authorize:
            return baseUrl.appendingPathComponent("oauth/authorize")
        case .getList:
            return baseUrl.appendingPathComponent("get")
        }
    }
    
    /// Returns the dict that needs to be transformed into the JSON body for the POST
    var payload: [String: String] {
        switch self {
        case .requestToken:
            return ["consumer_key" : "73483-2233031e613a5b40f9c466f7",
                    "redirect_uri" : "http://localhost.com"]
        case .authorize:
            return ["consumer_key" : "73483-2233031e613a5b40f9c466f7",
                    "code" : "c515a32e-ce5a-17c5-b968-2a6e41"]
        case .getList:
            return ["consumer_key" : "73483-2233031e613a5b40f9c466f7",
                    "access_token" : "1d4f85b9-eef9-c7d7-7c5e-b87071"]
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
        case .getList:
            return { (json: Any?) in
                guard let dict = json as? JSONDictionary else { return nil }
                guard let listAsDict = dict["list"] as? JSONDictionary else { return nil }
                let list = listAsDict.values.flatMap { $0 as? JSONDictionary }
                return list
            }
        }
    }
}
