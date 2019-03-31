//
//  URLRequest.swift
//  llitgi
//
//  Created by Xavi Moll on 16/12/2018.
//  Copyright © 2018 xmollv. All rights reserved.
//

import Foundation

#if DEBUG
// https://gist.github.com/peterprokop/16790dfa1320211b20c94a3f4dd95464
public extension URLRequest {
    
    /// Returns a cURL command for a request
    /// - return A String object that contains cURL command or "" if an URL is not properly initalized.
    var cURL: String {
        
        guard
            let url = url,
            let httpMethod = httpMethod,
            url.absoluteString.utf8.count > 0
            else {
                return ""
        }
        
        var curlCommand = "curl "
        
        // URL
        curlCommand = curlCommand.appendingFormat("'%@' ", url.absoluteString)
        
        // Method if different from GET
        if "GET" != httpMethod {
            curlCommand = curlCommand.appendingFormat("-X %@ ", httpMethod)
        }
        
        // Headers
        let allHeadersFields = allHTTPHeaderFields!
        let allHeadersKeys = Array(allHeadersFields.keys)
        let sortedHeadersKeys  = allHeadersKeys.sorted(by: <)
        for key in sortedHeadersKeys {
            curlCommand = curlCommand.appendingFormat("-H '%@: %@' ", key, self.value(forHTTPHeaderField: key)!)
        }
        
        // HTTP body
        if let httpBody = httpBody, httpBody.count > 0 {
            let httpBodyString = String(data: httpBody, encoding: String.Encoding.utf8)!
            let escapedHttpBody = URLRequest.escapeAllSingleQuotes(httpBodyString)
            curlCommand = curlCommand.appendingFormat("--data '%@' ", escapedHttpBody)
        }
        
        curlCommand = curlCommand.appending("| python -m json.tool")
        
        return curlCommand
    }
    
    /// Escapes all single quotes for shell from a given string.
    static func escapeAllSingleQuotes(_ value: String) -> String {
        return value.replacingOccurrences(of: "'", with: "'\\''")
    }
}
#endif
