//
//  HttpBackEnd.swift
//  NewsFeed
//
//  Created by Gokula K Narasimhan on 6/24/19.
//  Copyright © 2019 Gokul K Narasimhan. All rights reserved.
//

import Foundation

class HTTPBackEnd {
    var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30.0
        let s = URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
        return s
    }()
    
    
    func parseErrorFromResponse(_ response: URLResponse?, error: Error?) -> String? {
        guard let httpResponse = response as? HTTPURLResponse else {
            return "Unexpected error: not an HTTP response!"
        }
        if httpResponse.statusCode == 200 {
            return nil
        }
        return "HTTP Error \(httpResponse.statusCode): \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
    }
    
    
    func sendRequest(_ url: URL, rawDataDidArrive: @escaping (_ data: Data?, _ errorMsg: String?) -> Void) {
        let task = self.session.dataTask(with: url) { [weak self] (data: Data?, response: URLResponse?, error: Error?) in
            let errorMsg = self?.parseErrorFromResponse(response, error: error)
            rawDataDidArrive(data, errorMsg)
        }
        task.resume() 
    }
}
