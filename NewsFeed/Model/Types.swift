//
//  Types.swift
//  NewsFeed
//
//  Created by Gokula K Narasimhan on 6/24/19.
//  Copyright © 2019 Gokul K Narasimhan. All rights reserved.
//

import Foundation
let Center = NotificationCenter.default

protocol NewsProcessProtocol{
    func findNews()
    func getImage(iconURL : String, imageLoaded : @escaping (Data?, HTTPURLResponse?, Error?)->Void)
}
protocol NewsListDataSource:  NewsProcessProtocol{
    func valueFromSection(_ section: Int, atIndex index: Int) -> News?
    func sectionNameFromIndex(_ index: Int) -> String?
    func numSections() -> Int
    func numElementsInSection(_ section: Int) -> Int?
    
}

enum MessageType: String{
    case NewsFeedArrived = "News from web service arrive"
    
    var asNN: Notification.Name {
        return Notification.Name(self.rawValue)
    }
    var asNotification: Notification {
        return Notification(name: asNN)
    }
}

struct Consts{
    static let KEY0 = "Key0"
    
}

struct NewsFeedNotification {
    static func updateObservers(message: MessageType, data: Any? = nil) {
        Center.post(name: message.asNN, object: self, userInfo: {
            if let d = data {
                return [Consts.KEY0: d]
            }
            else {
                return nil
            }
        }())
    }
    
}
