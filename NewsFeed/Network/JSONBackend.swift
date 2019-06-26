//
//  JSONBackend.swift
//  NewsFeed
//
//  Created by Gokula K Narasimhan on 6/24/19.
//  Copyright © 2019 Gokul K Narasimhan. All rights reserved.
//

import Foundation

class JSONBackEnd: HTTPBackEnd {
       func networkRequest(_ url: URL,
                     parameters: [String: Any],
                     jsonDataDidArrive: @escaping (_ dataDict: NSDictionary?, _ errorMsg: String?) -> ()) {
        guard let queryURL = URL(string: "\(url.absoluteString)") else {
            jsonDataDidArrive(nil, "Internal library error")
            return
        }
         sendRequest(queryURL) {
            (data, errorMsg) in
            guard let rawData = data else {
                jsonDataDidArrive(nil, errorMsg)
                return
            }
            let json: Any?
            do {
                json = try JSONSerialization.jsonObject(with: rawData, options: JSONSerialization.ReadingOptions())
            } catch let error {
                 jsonDataDidArrive(nil, "\(error.localizedDescription)")
                return
            }
            
               guard let validParsedData = json as? NSDictionary else {
                 jsonDataDidArrive(nil, "Valid JSON data was not in dictionary form")
                return
            }
            
            jsonDataDidArrive(validParsedData, nil)
        }
    }
   
}
