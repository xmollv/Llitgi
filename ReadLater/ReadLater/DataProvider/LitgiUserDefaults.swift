//
//  LitgiUserDefaults.swift
//  ReadLater
//
//  Created by Xavi Moll on 03/02/2018.
//  Copyright © 2018 xmollv. All rights reserved.
//

import Foundation

let kAccesToken = "accessToken"
let kEnabledNotifications = "enabledNotifications"
let kSafariOpener = "safariOpener"
let kLastSync = "lastSync"

final class LitgiUserDefaults {
    private init() {}
    
    static let shared = UserDefaults(suiteName: "group.com.xmollv.litgi")!
    
    
    
}
