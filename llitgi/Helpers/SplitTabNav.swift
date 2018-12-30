//
//  SplitTabNav.swift
//  llitgi
//
//  Created by Xavi Moll on 22/12/2018.
//  Copyright © 2018 xmollv. All rights reserved.
//

import UIKit

class SplitViewController: UISplitViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.viewControllers.first?.preferredStatusBarStyle ?? .lightContent
    }
}

class TabBarController: UITabBarController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.selectedViewController?.preferredStatusBarStyle ?? .lightContent
    }
}

class NavigationController: UINavigationController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.topViewController?.preferredStatusBarStyle ?? .lightContent
    }
}
