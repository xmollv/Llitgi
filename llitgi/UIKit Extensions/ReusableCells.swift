//
//  ReusableCells.swift
//  llitgi
//
//  Created by Xavi Moll on 25/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import Foundation
import UIKit

/// This protocol only aggregates the needed properties for the extensions to work and avoid duplicated code.
private protocol Reusable: class {
    /// Returns `String(describing: self)` to be used as the `reuseIdentifier`.
    static var reuseIdentifier: String { get }
    /// Returns the UINib using the `String(describing: self)` as the name of the NIB.
    static var nib: UINib { get }
}

private extension Reusable {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
}

extension UITableViewCell: Reusable {}
extension UITableView {
    /// Registers a `UITableViewCell` using it's own `reuseIdentifier`. The `UITableViewCell` must be created using
    /// a `.xib` file with the same name, otherwise it will crash.
    func register<Cell: UITableViewCell>(_: Cell.Type) {
        self.register(Cell.nib, forCellReuseIdentifier: Cell.reuseIdentifier)
    }
    
    /// Dequeues a `UITableViewCell` and casts it to the expected type at the call site.
    func dequeueReusableCell<Cell: UITableViewCell>(for indexPath: IndexPath) -> Cell {
        guard let cell = self.dequeueReusableCell(withIdentifier: Cell.reuseIdentifier, for: indexPath) as? Cell else {
            fatalError("Unable to dequeue a \(String(describing: Cell.self)) cell.")
        }
        return cell
    }
}

extension UICollectionViewCell: Reusable {}
extension UICollectionView {
    /// Registers a `UICollectionViewCell` using it's own `reuseIdentifier`. The `UICollectionViewCell` must be created using
    /// a `.xib` file with the same name, otherwise it will crash.
    func register<Cell: UICollectionViewCell>(_: Cell.Type) {
        self.register(Cell.nib, forCellWithReuseIdentifier: Cell.reuseIdentifier)
    }
    
    /// Dequeues a `UICollectionViewCell` and casts it to the expected type at the call site.
    func dequeueReusableCell<Cell: UICollectionViewCell>(for indexPath: IndexPath) -> Cell {
        guard let cell = self.dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath) as? Cell else {
            fatalError("Unable to dequeue a \(String(describing: Cell.self)) cell.")
        }
        return cell
    }
}
