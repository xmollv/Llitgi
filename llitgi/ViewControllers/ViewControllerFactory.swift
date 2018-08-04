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
    
    private weak var flowManager: FlowManager?
    weak var safariShowing: SafariShowing?
    
    //MARK: Lifecycle
    init(dataProvider: DataProvider, userManager: UserManager, flowManager: FlowManager) {
        self.dataProvider = dataProvider
        self.userManager = userManager
        self.flowManager = flowManager
    }
    
    //MARK: Public methods
    func instantiateAuth() -> AuthorizationViewController {
        guard let flowManager = flowManager else {
            fatalError("need to inject flowManager into ViewControllerFactory")
        }
        return AuthorizationViewController(dataProvider: self.dataProvider, factory: self, flowManager: flowManager)
    }
    
    func instantiateList(for type: TypeOfList) -> ListViewController {
        guard let flowManager = flowManager , let safariShowing = safariShowing else {
            fatalError("need to inject flowManager and safariShowing into ViewControllerFactory")
        }
        return ListViewController(dataProvider: self.dataProvider, factory: self, userManager: self.userManager, type: type, flowManager: flowManager, safariShowing: safariShowing)
    }
    
    func instantiateSettings() -> SettingsViewController {
        return SettingsViewController(userManager: self.userManager)
    }
    
    func instantiateFullSync() -> FullSyncViewController {
        return FullSyncViewController(dataProvider: self.dataProvider)
    }
}
