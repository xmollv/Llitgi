//
//  SyncManager.swift
//  llitgi
//
//  Created by Xavi Moll on 03/02/2018.
//  Copyright © 2018 xmollv. All rights reserved.
//

import Foundation

final class SyncManager {
    
    private let dataProvider: DataProvider
    private var lastSync: TimeInterval {
        get { return LlitgiUserDefaults.shared.double(forKey: kLastSync) }
        set { LlitgiUserDefaults.shared.set(newValue, forKey: kLastSync) }
    }
    private var isSyncing = false
    
    init(dataProvider: DataProvider) {
        self.dataProvider = dataProvider
    }
    
    func sync(then: @escaping Completion<[CoreDataItem]>) {
        guard !self.isSyncing else {
            then(Result.isFailure(AppError.isAlreadyFetching))
            return
        }
        self.isSyncing = true
        
        let endpoint: PocketAPIEndpoint
        if self.lastSync == 0 {
            Logger.log("Last sync was 0", event: .warning)
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
