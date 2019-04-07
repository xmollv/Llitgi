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
    
    var tags: [Tag] {
        return self.modelFactory.tags
    }
    
    var tagsNotifier: CoreDataNotifier<CoreDataTag> {
        return self.modelFactory.tagsNotifier
    }
    
    var badgeNotifier: CoreDataNotifier<CoreDataItem> {
        return self.modelFactory.badgeNotifier
    }
    
    //MARK: Lifecycle
    init(pocketAPI: PocketAPIManager, modelFactory: CoreDataFactory) {
        self.pocketAPI = pocketAPI
        self.modelFactory = modelFactory
    }
    
    //MARK: Public methods
    func notifier(for type: TypeOfList, filteredBy query: String? = nil) -> CoreDataNotifier<CoreDataItem> {
        return self.modelFactory.notifier(for: type, matching: query)
    }
    
    func notifier(for tag: Tag) -> CoreDataNotifier<CoreDataItem> {
        return self.modelFactory.notifier(for: tag)
    }
    
    /// Performs a network request based on the endpoint, and builds the objects that the API returned
    func perform<T: Managed>(endpoint: PocketAPIEndpoint,
                             on resultQueue: DispatchQueue = DispatchQueue.main,
                             then: @escaping (Result<[T]>) -> ()) {
        self.pocketAPI.perform(endpoint: endpoint) { [weak self] (result: Result<JSONArray>) in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let json):
                let elements: [T] = strongSelf.modelFactory.build(jsonArray: json)
                resultQueue.async {
                    then(Result.success(elements))
                }
            case .failure(let error):
                resultQueue.async {
                    then(Result.failure(error))
                }
            }
        }
    }
    
    /// Performs a network request based on the endpoint and returns a memory only object.
    func performInMemory<T: JSONInitiable>(endpoint: PocketAPIEndpoint,
                                   on resultQueue: DispatchQueue = DispatchQueue.main,
                                   then: @escaping (Result<[T]>) -> ()) {
        self.pocketAPI.perform(endpoint: endpoint) { (result: Result<JSONArray>) in
            switch result {
            case .success(let json):
                let builtElements = json.compactMap{ T(dict: $0) }
                resultQueue.async {
                    then(Result.success(builtElements))
                }
            case .failure(let error):
                resultQueue.async {
                    then(Result.failure(error))
                }
            }
        }
    }
    
    /// Used only for API calls that we don't need the response (e.g: toggle favorite)
    func performInMemoryWithoutResultType(endpoint: PocketAPIEndpoint,
                 on resultQueue: DispatchQueue = DispatchQueue.main,
                 then: ((EmptyResult) -> ())? = nil) {
        self.pocketAPI.perform(endpoint: endpoint) { (result: Result<JSONArray>) in
            guard let completion = then else { return }
            switch result {
            case .success:
                resultQueue.async {
                    completion(EmptyResult.success)
                }
            case .failure(let error):
                resultQueue.async {
                    completion(EmptyResult.failure(error))
                }
            }
        }
    }
    
    func syncLibrary(fullSync: Bool = false, then: @escaping (Result<[Item]>) -> ()) {
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
            case .success(let items):
                strongSelf.lastSync = Date().timeIntervalSince1970
                then(Result.success(items))
            case .failure(let error):
                then(Result.failure(error))
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
