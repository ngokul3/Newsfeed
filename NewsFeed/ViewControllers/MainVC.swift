
import UIKit

class MainVC: UIViewController {
    var loadImageForChild: ((NSInteger, UIImageView)->Void)?
    @IBOutlet weak var tableView: UITableView!
    private let model: NewsListDataSource = NewsListModel()
    var imageCache = NSCache<AnyObject, NSData>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Center.addObserver(forName: MessageType.NewsFeedArrived.asNN, object: nil, queue: OperationQueue.main) {
            [weak self] (notification) in
            self?.tableView.reloadData()
        }
        
        model.findNews()
    }
}

extension MainVC:UITableViewDataSource, UITableViewDelegate{
   
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return model.numSections()
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as? NewsViewCell else{
            preconditionFailure("Incorrect Cell provided")
        }
        
        
        
        if let newsObj = model.valueFromSection(indexPath.section, atIndex: indexPath.row){
            cell.titleLabel.text = newsObj.title
          
            if let iconURL = newsObj.imageURL{
                if let imageFromCache = self.imageCache.object(forKey: (indexPath.row ) as AnyObject) {
                    cell.thumbnailImage.image = UIImage(data: imageFromCache as Data)
                    
                    return cell
                }else{
                    cell.thumbnailImage.image = nil
                }
                model.getImage(iconURL: iconURL) {[weak self] (data,response,error) in
                    OperationQueue.main.addOperation {
                        
                        if let e = error {
                            print("HTTP request failed: \(e.localizedDescription)")
                            cell.thumbnailImage.image = nil
                        }
                        else{
                            if let httpResponse = response {
                                print("http response code: \(httpResponse.statusCode)")
                                
                                let HTTP_OK = 200
                                if(httpResponse.statusCode == HTTP_OK ){
                                    
                                    if let imageData = data,
                                        let image = UIImage(data: imageData){
                                        print("urlArrivedCallback operation: Now on thread: \(Thread.current)")
                                            cell.thumbnailImage.image = image
                                            self?.imageCache.setObject(imageData as NSData, forKey: (indexPath.row) as AnyObject)
                                            tableView.reloadRows(at: [indexPath], with: .none)
                                            self?.loadImageForChild = {(arg1, arg2) in
                                                if(arg1 == indexPath.row){
                                                    arg2.image = image
                                                }
                                        }
                                    }
                                    else{
                                        cell.thumbnailImage.image = nil
                                        print("Image data not available")
                                    }
                                }
                                else{
                                    cell.thumbnailImage.image = nil
                                    print("HTTP Error \(httpResponse.statusCode)")
                                }
                            }
                            else{
                                cell.thumbnailImage.image = nil
                                print("Can't parse imageresponse")
                            }
                        }
                    }
                }
            }else{
                cell.thumbnailImage.image = nil
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         guard let numRows = model.numElementsInSection(section) else {
            NSLog("Unexpected section request: \(section)")
            return 0
        }
         return numRows
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model.sectionNameFromIndex(section)
    }
}

extension MainVC{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        guard let _ = segue.identifier else{
            preconditionFailure("No segue identifier")
        }
        
        guard let vc = segue.destination as? DetailVC else{
            preconditionFailure("Could not find segue")
        }
        
        guard let cell = sender as? UITableViewCell,
            let indexPath = self.tableView.indexPath(for: cell) else{
                preconditionFailure("Segue from unexpected object: \(sender ?? "sender = nil")")
        }
        
        do{
            if let newsFeed = model.valueFromSection(indexPath.section, atIndex: indexPath.row){
                vc.newsObj = newsFeed
                vc.loadImage = {[weak self] in
                     OperationQueue.main.addOperation {
                        if let imageFromCache = self?.imageCache.object(forKey: (indexPath.row ) as AnyObject) {
                                vc.newsImage.image = UIImage(data:imageFromCache as Data)
                        }else{
                            self?.loadImageForChild?(indexPath.row, vc.newsImage)
                            vc.hieghtConstraint.constant = 0
                        }
                    }
                }
            }
            
        }
    }
}
