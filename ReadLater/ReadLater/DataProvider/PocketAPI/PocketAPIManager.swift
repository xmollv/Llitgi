//
//  PocketAPIManager.swift
//  ReadLater
//
//  Created by Xavi Moll on 24/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import Foundation

final class PocketAPIManager {
    
    //MARK:- Private properties
    private let session: URLSession
    private let apiConfig = PocketAPIConfiguration()
    
    //MARK:- Public properties
    var OAuthURLApp: URL? {
        get {
            return self.url(for: .app)
        }
    }
    
    var OAuthURLWebsite: URL? {
        get {
            return self.url(for: .web)
        }
    }
    
    //MARK:- Lifecycle
    init(session: URLSession = URLSession(configuration: .default)) {
        self.session = session
    }
    
    //MARK:- Public methods
    /// Calls the given endpoint and runs the closure on completion
    func perform(endpoint: PocketAPIEndpoint, then completion: @escaping Completion<JSONArray>) {
        
        var request = URLRequest(url: endpoint.url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
        request.httpMethod = "POST" // The Pocket API only accepts POSTs
        request.addValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "X-Accept")
        
        let payload = self.payload(for: endpoint)
        
        do {
            let jsonBody = try JSONSerialization.data(withJSONObject: payload, options: [])
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
    
    func updatePocket(code: String) {
        self.apiConfig.authCode = code
    }
    
    func updatePocket(token: String) {
        self.apiConfig.accessToken = token
    }

    //MARK:- Private methods
    private enum TypeOfOAuthUrl {
        case app
        case web
    }
    
    /// Returns the dict that needs to be transformed into the JSON body for the POST
    private func payload(for endpoint: PocketAPIEndpoint) -> [String: String] {
        var payload = ["consumer_key" : self.apiConfig.consumerKey]
        switch endpoint {
        case .requestToken:
            payload["redirect_uri"] = self.apiConfig.redirectUri
        case .authorize:
            guard let authCode = self.apiConfig.authCode else { break }
            payload["code"] = authCode
        case .getList:
            guard let token = self.apiConfig.accessToken else { break }
            payload["access_token"] = token
        }
        return payload
    }
    
    private func url(for type: TypeOfOAuthUrl) -> URL? {
        guard let requestToken = self.apiConfig.authCode else { return nil }
        let redirectURI = self.apiConfig.redirectUri
        let url: URL?
        switch type {
        case .app:
            url =  URL(string: "pocket-oauth-v1:///authorize?request_token=\(requestToken)&redirect_uri=\(redirectURI)")
        case .web:
            url =  URL(string: "https://getpocket.com/auth/authorize?request_token=\(requestToken)&redirect_uri=\(redirectURI)")
        }
        return url
    }
}
