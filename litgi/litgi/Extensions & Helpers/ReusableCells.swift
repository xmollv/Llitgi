//
//  ReusableCells.swift
//  litgi
//
//  Created by Xavi Moll on 25/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import Foundation
import UIKit

public protocol ReusableView: class {
    static var defaultReuseIdentifier: String { get }
}

public protocol NibLoadableView: class {
    static var nibName: String { get }
    static var nib: UINib { get }
}

public extension ReusableView where Self: UIView {
    static var defaultReuseIdentifier: String {
        return String(describing: self)
    }
}

public extension NibLoadableView where Self: UIView {
    static var nibName: String {
        let nibName = String(describing: self)
        return nibName
    }
    static var nib: UINib {
        let bundle = Bundle(for: self)
        let nib = UINib(nibName: self.nibName, bundle: bundle)
        return nib
    }
}

extension UITableViewCell: ReusableView { }

extension UITableView {
    
    public func register<T: UITableViewCell>(_: T.Type) where T: NibLoadableView {
        self.register(T.nib, forCellReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    func dequeueReusableCell<T: UITableViewCell>(forIndexPath indexPath: IndexPath) -> T {
        guard let cell = self.dequeueReusableCell(withIdentifier: T.defaultReuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier)")
        }
        
        return cell
    }
}
