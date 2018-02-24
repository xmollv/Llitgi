//
//  SyncManager.swift
//  llitgi
//
//  Created by Xavi Moll on 03/02/2018.
//  Copyright © 2018 xmollv. All rights reserved.
//

import Foundation

final class SyncManager {
    
    //MARK: Private properties
    private let dataProvider: DataProvider
    private var lastSync: TimeInterval {
        get { return LlitgiUserDefaults.shared.double(forKey: kLastSync) }
        set { LlitgiUserDefaults.shared.set(newValue, forKey: kLastSync) }
    }
    private var isSyncing = false
    
    //MARK: Lifecycle
    init(dataProvider: DataProvider) {
        self.dataProvider = dataProvider
    }
    
    //MARK: Public methods
    func sync(fullSync: Bool = false, then: @escaping Completion<[CoreDataItem]>) {
        guard !self.isSyncing else {
            then(Result.isFailure(AppError.isAlreadyFetching))
            return
        }
        self.isSyncing = true
        
        let endpoint: PocketAPIEndpoint
        if fullSync || self.lastSync == 0 {
            Logger.log("Last sync was 0 or you've forced a fullsync", event: .warning)
            endpoint = .getAll
        } else {
            Logger.log("Last sync was \(self.lastSync)")
            endpoint = .sync(last: self.lastSync)
        }
        
        self.dataProvider.perform(endpoint: endpoint) { [weak self] (result: Result<[CoreDataItem]>) in
            guard let strongSelf = self else { return }
            strongSelf.isSyncing = false
            switch result {
            case .isSuccess:
                strongSelf.lastSync = Date().timeIntervalSince1970
            case .isFailure: break
            }
            then(result)
        }
    }
    
}
