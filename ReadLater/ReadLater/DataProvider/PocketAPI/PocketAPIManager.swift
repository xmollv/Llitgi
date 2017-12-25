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
    
    /// Calls the given endpoint and runs the closure on completion
    func perform(endpoint: PocketAPIEndpoint, then completion: @escaping Completion<JSONArray>) {
        
        var request = URLRequest(url: endpoint.url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
        request.httpMethod = "POST" // The Pocket API only accepts POSTs
        request.addValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "X-Accept")
        
        do {
            let jsonBody = try JSONSerialization.data(withJSONObject: endpoint.payload, options: [])
            request.httpBody = jsonBody
        } catch {
            completion(Result.isFailure(PocketAPIError.unableToCreateHTTPBody(error: error)))
            return
        }
        
        self.session.dataTask(with: request) { (data, urlResponse, error) in
            if let error = error {
                completion(Result.isFailure(PocketAPIError.unknown(error: error)))
                return
            }
            
            guard let response = urlResponse as? HTTPURLResponse else {
                completion(Result.isFailure(PocketAPIError.unexpectedResponse(response: urlResponse)))
                return
            }
            
            guard let data = data else {
                Logger.log("The response was sucessful but the data is nil. Returning an empry array on the success")
                completion(Result.isSuccess([]))
                return
            }
            
            switch response.statusCode {
            case 200...299:
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    guard let jsonParsed = endpoint.parser(json) else {
                        completion(Result.isFailure(PocketAPIError.unexpectedJSONFormat))
                        return
                    }
                    completion(Result.isSuccess(jsonParsed))
                } catch {
                    completion(Result.isFailure(PocketAPIError.unknown(error: error)))
                }
            default:
                completion(Result.isFailure(PocketAPIError.not200Status(statusCode: response.statusCode)))
            }
        }.resume()
    }
}
