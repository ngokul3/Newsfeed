//
//  NewsModel.swift
//  NewsFeed
//
//  Created by Gokula K Narasimhan on 6/24/19.
//  Copyright © 2019 Gokul K Narasimhan. All rights reserved.
//

import Foundation

class NewsListModel: NewsListDataSource{
    let host = "www.reddit.com/r/swift/.json"
    let webProtocol = "https"
    private var newsList = [News]()
    var params: [String: Any] = [
        "with_original_language": "en"
    ]
    let json = JSONBackEnd()
    let image = ImageDownloadBackEnd()
    
    func findNews() {
        guard let newsURL = URL(string: "\(webProtocol)://\(host)") else {
            print("bad url!")
            return
        }
        
        json.networkRequest(newsURL, parameters: params) { (dictionary, error) in
            print("In return from ajaxRequest: \(Thread.current)")
            
               guard let valueDict = dictionary?["data"] as?  [String: AnyObject]  else {
                print("data format error: \(dictionary?.description ?? "[Missing dictionary]")")
                return
            }
            
            guard let newsResultArrayDict = valueDict["children"] as? [[String: AnyObject]] else{
                return
            }
            
            OperationQueue.main.addOperation {
                newsResultArrayDict.forEach({ [weak self](newsDict) in
                    let news = News()
                    if let dataDict = newsDict["data"] as? [String: AnyObject]{
                        news.imageURL = dataDict["thumbnail"] as? String
                        news.title = dataDict["title"] as? String
                        news.newsURL = dataDict["url"] as? String
                        self?.newsList.append(news)
                    }
                })
                NewsFeedNotification.updateObservers(message: MessageType.NewsFeedArrived)
            }
        }
    }
    
    func getImage(iconURL : String, imageLoaded : @escaping (Data?, HTTPURLResponse?, Error?)->Void){
        image.getImage(iconURL: iconURL) { (data, httpresponse, error) in
            imageLoaded(data, httpresponse, error)
        }
    }
    
    func valueFromSection(_ section: Int, atIndex index: Int) -> News? {
        return self.newsList[index]
    }
    
    func sectionNameFromIndex(_ index: Int) -> String? {
        return "News"
    }
    
    func numSections() -> Int {
        return 1
    }
    
    func numElementsInSection(_ section: Int) -> Int? {
        return newsList.count
    }
    
   
}


class News{
    var imageURL: String?
    var title: String?
    var newsURL: String?
}
