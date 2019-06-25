//
//  DetailVC.swift
//  NewsFeed
//
//  Created by Gokula K Narasimhan on 6/24/19.
//  Copyright © 2019 Gokul K Narasimhan. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class DetailVC: UIViewController{

    @IBOutlet weak var webView: WKWebView!
    var newsURL: String?
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var newsImage: UIImageView!
    var loadImage:(() -> Void)?
    
    @IBAction func backbuttonClicked(_ sender: UIBarButtonItem) {
         self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        loadImage?()
        if let url1 = newsURL{
            let request = URLRequest(url: URL(string: url1)!)
            self.webView.load(request)
        }
      
    }
}
