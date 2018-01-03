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
    private let modelFactory: CoreDataFactory
    
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
    
    init(pocketAPI: PocketAPIManager, modelFactory: CoreDataFactory) {
        self.pocketAPI = pocketAPI
        self.modelFactory = modelFactory
    }
    
    /// Performs a network request based on the endpoint, and builds the objects that the API returned
    func perform<T: Managed>(endpoint: PocketAPIEndpoint,
                             clearCachedData: Bool,
                             typeOfList: TypeOfList,
                             on resultQueue: DispatchQueue = DispatchQueue.main,
                             then: @escaping Completion<[T]>) {
        self.pocketAPI.perform(endpoint: endpoint) { (result: Result<JSONArray>) in
            switch result {
            case .isSuccess(let json):
                let elements: [T] = self.modelFactory.build(jsonArray: json, for: typeOfList, clearCache: clearCachedData)
                resultQueue.async {
                    then(Result.isSuccess(elements))
                }
            case .isFailure(let error):
                resultQueue.async {
                    then(Result.isFailure(error))
                }
            }
        }
    }
    
    func notifier(for type: TypeOfList) -> CoreDataNotifier {
        return self.modelFactory.notifier(for: type)
    }
    
    /// Performs a network request based on the endpoint and returns a memory only object.
    func performInMemory<T: JSONInitiable>(endpoint: PocketAPIEndpoint,
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
    func performInMemoryWithoutResultType(endpoint: PocketAPIEndpoint,
                 on resultQueue: DispatchQueue = DispatchQueue.main,
                 then: EmptyCompletion? = nil) {
        self.pocketAPI.perform(endpoint: endpoint) { (result: Result<JSONArray>) in
            guard let completion = then else { return }
            switch result {
            case .isSuccess:
                resultQueue.async {
                    completion(EmptyResult.isSuccess)
                }
            case .isFailure(let error):
                resultQueue.async {
                    completion(EmptyResult.isFailure(error))
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
