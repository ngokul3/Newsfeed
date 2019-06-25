
import UIKit

class MainVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private let model: NewsListDataSource = NewsListModel()
    let imageCache = NSCache<AnyObject, AnyObject>()
    
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
                model.getImage(iconURL: iconURL, imageLoaded: {[weak self] (data, responseOpt, error) in
                    if let e = error {
                        print("Error downloading icon: \(e)")
                        //Take custom actions
                    }else{
                        if let response = responseOpt {
                            
                            if let imageData = data {
                                OperationQueue.main.addOperation {
                                    if let iconImage = UIImage(data: imageData){
                                        self?.imageCache.setObject(iconImage, forKey: (iconURL) as AnyObject)
                                        OperationQueue.main.addOperation {
                                             cell.thumbnailImage.image = UIImage(data: imageData)
                                        }
                                    }
                                   
                                }
                                
                            }
                            else {
                                print(response)
                            }
                        }
                        else {
                            print(error.debugDescription)
                        }
                    }
                })
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
            if let newsFeed = model.valueFromSection(0, atIndex: indexPath.row){
                vc.newsURL = newsFeed.newsURL
                vc.loadImage = {[weak self] in
                    
                    if let imageFromCache = self?.imageCache.object(forKey: (newsFeed.newsURL ?? "" ) as AnyObject) as? UIImage{
                        OperationQueue.main.addOperation {
                            vc.newsImage.image = imageFromCache
                        }
                    }else{
                        
                    }
                }
            }
            
        }
    }
}
