//
//  PocketEndpoint.swift
//  ReadLater
//
//  Created by Xavi Moll on 24/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import Foundation

enum PocketEndpoint {
    // Authorization endpoints
    case requestToken
    case authorize
    
    // Already authorized endpoints
    case list
    
    /// Returns the full URL to perform the request
    var url: URL {
        let baseUrl = URL(string: "https://getpocket.com/v3")!
        switch self {
        case .requestToken:
            return baseUrl.appendingPathComponent("oauth/request")
        case .authorize:
            return baseUrl.appendingPathComponent("oauth/authorize")
        case .list:
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
        case .list:
            return ["consumer_key" : "73483-2233031e613a5b40f9c466f7",
                    "access_token" : "1d4f85b9-eef9-c7d7-7c5e-b87071"]
        }
    }
}
