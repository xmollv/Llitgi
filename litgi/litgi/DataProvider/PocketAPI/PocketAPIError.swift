//
//  PocketAPIError.swift
//  litgi
//
//  Created by Xavi Moll on 25/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import Foundation

enum PocketAPIError: Error {
    case unableToCreateHTTPBody(error: Error)
    case unknown(error: Error)
    case unexpectedResponse(response: URLResponse?)
    case not200Status(statusCode: Int)
    case unexpectedJSONFormat
}

enum AppError: Error {
    case isAlreadyFetching
}
