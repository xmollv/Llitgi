//
//  CoreDataFactory.swift
//  ReadLater
//
//  Created by Xavi Moll on 27/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import Foundation

protocol CoreDataFactory: class {
    func build<T>(jsonArray: JSONArray) -> [T]
    func notifier<T>(for: T.Type) -> CoreDataNotifier
}
