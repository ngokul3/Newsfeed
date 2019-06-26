//
//  ImageDownloadBackEnd.swift
//  NewsFeed
//
//  Created by Gokula K Narasimhan on 6/24/19.
//  Copyright © 2019 Gokul K Narasimhan. All rights reserved.
//

import Foundation

class ImageDownloadBackEnd: HTTPBackEnd{
    func getImage(iconURL : String, imageLoaded : @escaping (Data?, HTTPURLResponse?, Error?)->Void) {
        
        if let teamIconURL = URL(string: iconURL)
        {
            let downloadPicTask = session.dataTask(with: teamIconURL) { (data, responseOpt, error) in
                if let _ = error {
                }
                else {
                    if let response = responseOpt as? HTTPURLResponse {
                        
                        if let imageData = data {
                            imageLoaded(imageData, response, error)
                        }
                        else {
                            imageLoaded(nil, response, error)
                        }
                    }
                    else {
                        imageLoaded(nil, nil, error)
                    }
                }
            }
            downloadPicTask.resume()
        }
    }
}
