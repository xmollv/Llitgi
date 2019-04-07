//
//  Typealias.swift
//  llitgi
//
//  Created by Xavi Moll on 25/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import Foundation

typealias Result<T> = Swift.Result<T, Error>

enum EmptyResult {
    case success
    case failure(Error)
}
