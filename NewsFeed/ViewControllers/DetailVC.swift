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
    var newsObj: News?
    
    @IBOutlet weak var imageView: UIView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var newsImage: UIImageView!
    var loadImage:(() -> Void)?
    
    @IBOutlet weak var hieghtConstraint: NSLayoutConstraint!
    @IBAction func backbuttonClicked(_ sender: UIBarButtonItem) {
         self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        loadImage?()
        hieghtConstraint.constant = 105
        if let url1 = newsObj?.newsURL{
            let request = URLRequest(url: URL(string: url1)!)
            self.webView.load(request)
        }
        navigationBar.topItem?.title = newsObj?.title
      
    }
}
