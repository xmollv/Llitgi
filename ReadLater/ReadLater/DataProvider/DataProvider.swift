//
//  DataProvider.swift
//  ReadLater
//
//  Created by Xavi Moll on 24/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import Foundation

protocol JSONInitiable {
    init?(dict: JSONDictionary)
}

final class DataProvider {
    
    private let pocketAPI: PocketAPIManager
    
    var urlForPocketOAuthApp: URL? {
        get {
            return self.pocketAPI.OAuthURLApp
        }
    }
    
    var urlForPocketOAuthWebsite: URL? {
        get {
            return self.pocketAPI.OAuthURLWebsite
        }
    }
    
    init(pocketAPI: PocketAPIManager) {
        self.pocketAPI = pocketAPI
    }
    
    func perform<T: JSONInitiable>(endpoint: PocketAPIEndpoint,
                                   on resultQueue: DispatchQueue = DispatchQueue.main,
                                   then: @escaping Completion<[T]>) {
        self.pocketAPI.perform(endpoint: endpoint) { (result: Result<JSONArray>) in
            switch result {
            case .isSuccess(let json):
                let builtElements = json.flatMap{ T(dict: $0) }
                resultQueue.async {
                    then(Result.isSuccess(builtElements))
                }
            case .isFailure(let error):
                resultQueue.async {
                    then(Result.isFailure(error))
                }
            }
        }
    }
    
    /// Used only for API calls that we don't need the response (e.g: toggle favorite)
    func perform(endpoint: PocketAPIEndpoint, on resultQueue: DispatchQueue = DispatchQueue.main) {
        self.pocketAPI.perform(endpoint: endpoint) { (result: Result<JSONArray>) in }
    }
    
    func updatePocket(code: String) {
        self.pocketAPI.updatePocket(code: code)
    }
    
    func updatePocket(token: String) {
        self.pocketAPI.updatePocket(token: token)
    }
    
}
