//
//  ViewControllerFactory.swift
//  llitgi
//
//  Created by Xavi Moll on 24/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import Foundation
import UIKit

final class ViewControllerFactory {
    
    //MARK: Private properties
    private let dataProvider: DataProvider
    private let userManager: UserManager
    private let flowManager: FlowManager
    var safariShowing: SafariShowing!
    
    //MARK: Lifecycle
    init(dataProvider: DataProvider, userManager: UserManager, flowManager: FlowManager) {
        self.dataProvider = dataProvider
        self.userManager = userManager
        self.flowManager = flowManager
    }
    
    //MARK: Public methods
    func instantiateAuth() -> AuthorizationViewController {
        return AuthorizationViewController(dataProvider: self.dataProvider, factory: self, flowManager: self.flowManager)
    }
    
    func instantiateList(for type: TypeOfList) -> ListViewController {
        return ListViewController(dataProvider: self.dataProvider, factory: self, userManager: self.userManager, type: type, flowManager: self.flowManager, safariShowing: safariShowing)
    }
    
    func instantiateSettings() -> SettingsViewController {
        return SettingsViewController(userManager: self.userManager)
    }
    
    func instantiateFullSync() -> FullSyncViewController {
        return FullSyncViewController(dataProvider: self.dataProvider)
    }
}
