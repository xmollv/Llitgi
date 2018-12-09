//
//  DataProvider.swift
//  llitgi
//
//  Created by Xavi Moll on 24/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import Foundation

final class DataProvider {
    
    //MARK: Private properties
    private let pocketAPI: PocketAPIManager
    private let modelFactory: CoreDataFactory
    private var isSyncing = false
    private var lastSync: TimeInterval {
        get { return LlitgiUserDefaults.shared.double(forKey: kLastSync) }
        set { LlitgiUserDefaults.shared.set(newValue, forKey: kLastSync) }
    }
    
    //MARK: Public properties
     var pocketOAuthUrl: URL? {
        return self.pocketAPI.OAuthURLWebsite
    }
    
    //MARK: Lifecycle
    init(pocketAPI: PocketAPIManager, modelFactory: CoreDataFactory) {
        self.pocketAPI = pocketAPI
        self.modelFactory = modelFactory
    }
    
    //MARK: Public methods
    func badgeNotifier() -> CoreDataNotifier {
        return self.modelFactory.badgeNotifier()
    }
    
    func notifier(for type: TypeOfList, filteredBy query: String? = nil) -> CoreDataNotifier {
        return self.modelFactory.notifier(for: type, matching: query)
    }
    
    /// Performs a network request based on the endpoint, and builds the objects that the API returned
    func perform<T: Managed>(endpoint: PocketAPIEndpoint,
                             on resultQueue: DispatchQueue = DispatchQueue.main,
                             then: @escaping Completion<[T]>) {
        self.pocketAPI.perform(endpoint: endpoint) { [weak self] (result: Result<JSONArray>) in
            guard let strongSelf = self else { return }
            switch result {
            case .isSuccess(let json):
                let elements: [T] = strongSelf.modelFactory.build(jsonArray: json)
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
    
    /// Performs a network request based on the endpoint and returns a memory only object.
    func performInMemory<T: JSONInitiable>(endpoint: PocketAPIEndpoint,
                                   on resultQueue: DispatchQueue = DispatchQueue.main,
                                   then: @escaping Completion<[T]>) {
        self.pocketAPI.perform(endpoint: endpoint) { (result: Result<JSONArray>) in
            switch result {
            case .isSuccess(let json):
                let builtElements = json.compactMap{ T(dict: $0) }
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
    
    func syncLibrary(fullSync: Bool = false, then: @escaping Completion<[Item]>) {
        guard !self.isSyncing else { return }
        self.isSyncing = true
        
        let endpoint: PocketAPIEndpoint
        if fullSync || self.lastSync == 0 {
            endpoint = .sync(last: nil)
        } else {
            endpoint = .sync(last: self.lastSync)
        }
        
        self.perform(endpoint: endpoint) { [weak self] (result: Result<[CoreDataItem]>) in
            guard let strongSelf = self else { return }
            strongSelf.isSyncing = false
            switch result {
            case .isSuccess(let items):
                strongSelf.lastSync = Date().timeIntervalSince1970
                then(Result.isSuccess(items))
            case .isFailure(let error):
                then(Result.isFailure(error))
            }
        }
    }
    
    func clearLocalStorage() {
        LlitgiUserDefaults.shared.removePersistentDomain(forName: kGroupUserDefaults)
        self.modelFactory.deleteAllModels()
    }
    
    func updatePocket(code: String) {
        self.pocketAPI.updatePocket(code: code)
    }
    
    func updatePocket(token: String) {
        self.pocketAPI.updatePocket(token: token)
    }
}
