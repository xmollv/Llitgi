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
    
    func updatePocket(code: String) {
        self.pocketAPI.updatePocket(code: code)
    }
    
    func updatePocket(token: String) {
        self.pocketAPI.updatePocket(token: token)
    }
    
}
