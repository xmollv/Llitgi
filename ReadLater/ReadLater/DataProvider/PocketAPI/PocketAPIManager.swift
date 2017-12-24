//
//  PocketAPIManager.swift
//  ReadLater
//
//  Created by Xavi Moll on 24/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import Foundation

final class PocketAPIManager {
    
    private let session: URLSession
    private let apiConfig = PocketAPIConfiguration()
    
    init(session: URLSession = URLSession(configuration: .default)) {
        self.session = session
    }
    
}
