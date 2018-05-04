//
//  UltraKlinHistoryView.swift
//  UltraKlin
//
//  Created by Lini on 22/02/18.
//  Copyright © 2018 PT Lintas Insan Nur Inspira. All rights reserved.
//

import UIKit
import Foundation

struct MyHistory {
    let imageHistory: UIImage
    let produk: String
    let status: String
    var date: String
}

class UltraKlinTableHistoryOrder : UITableViewCell {
    @IBOutlet weak var imageHistory: UIImageView!
    @IBOutlet weak var labelProduk: UILabel!
    @IBOutlet weak var labelPrices: UILabel!
    @IBOutlet weak var labelDate: UILabel!
}

class UltraKlinHistoryView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var auth : String?
    
    var loadedDetail : [[String: Any]] = []
    
    var historyOrder : [MyHistory] = []
    
    let swipeRight = UISwipeGestureRecognizer()
    let swipeLeft = UISwipeGestureRecognizer()
    
    var pageNo: Int = 0
    var pagelimit: Int = 0
    
    // Refresh
    let messageFrame = UIView()
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableHistoryOrderCustomers: UITableView!
    @IBOutlet weak var pageHistory: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.lightGray.cgColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 2.0
        self.navigationController?.navigationBar.layer.shadowOpacity = 1
        self.navigationController?.navigationBar.layer.masksToBounds = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        auth = (UserDefaults.standard.string(forKey: "SavedApiToken"))
        checkingSession()
    }
    
    @objc func swipedTouch(gesture : UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("User swiped right")
                if auth != nil {
                    if pageHistory.currentPage == 0 {
                        pageHistory.currentPage = pagelimit-1
                    } else {
                        pageHistory.currentPage -= 1
                    }
                    let transition = CATransition()
                    transition.type = kCATransitionPush
                    transition.subtype = kCATransitionFromLeft
                    tableHistoryOrderCustomers.layer.add(transition, forKey: kCATransition)
                    dataRequestHistory()
                }
            case UISwipeGestureRecognizerDirection.left:
                print("User swiped left")
                if auth != nil {
                    if pageHistory.currentPage == pagelimit-1 {
                        pageHistory.currentPage = 0
                    } else {
                        pageHistory.currentPage += 1
                    }
                    let transition = CATransition()
                    transition.type = kCATransitionPush
                    transition.subtype = kCATransitionFromRight
                    tableHistoryOrderCustomers.layer.add(transition, forKey: kCATransition)
                    dataRequestHistory()
                }
            default:
                break
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyOrder.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellHistory", for: indexPath) as! UltraKlinTableHistoryOrder
        cell.imageHistory.image = historyOrder[indexPath.row].imageHistory
        cell.labelProduk.text = historyOrder[indexPath.row].produk
        cell.labelDate.text = historyOrder[indexPath.row].date
        cell.labelPrices.text = historyOrder[indexPath.row].status
        return cell
    }
    
    func checkingSession() {
        if auth == nil {
            // User not yet login ======================
            let alert = UIAlertController(title: "Login", message: "You must login first.", preferredStyle: .alert)
            let loginAction = UIAlertAction(title: "Login", style: .default) {
                (action) -> Void in
                // Login
                let myVC = self.storyboard?.instantiateViewController(withIdentifier: "ultraKlinLogin") as! UltraKlinLogin
                myVC.skipLogin = "Login"
                myVC.hiddenActLogin = true
                self.navigationController?.pushViewController(myVC, animated: true)
            }
            let regisAction = UIAlertAction(title: "Register", style: .default) {
                (action) -> Void in
                // Login
                let myVC = self.storyboard?.instantiateViewController(withIdentifier: "ultraKlinRegistration") as! UltraKlinRegistration
                myVC.skipRegis = "Regis"
                myVC.hiddenActRegis = true
                self.navigationController?.pushViewController(myVC, animated: true)
            }
            let cancelAction = UIAlertAction(title: "Not now", style: .cancel) {
                UIAlertAction in
            }
            alert.addAction(loginAction)
            alert.addAction(regisAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            dataRequestHistory()
        }
    }
    
    func dataRequestHistory() {
        loadingData()
        // ======================== Dinamis List Item Laundry =========================
        if Reachability.isConnectedToNetwork() {
            print("Internet Connection Available!")
            let url = URL(string: Config().URL_History + "?page=\(pageHistory.currentPage+1)")!
            
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = TimeInterval(15)
            config.timeoutIntervalForResource = TimeInterval(15)
            
            let session = URLSession(configuration: config)
            //let session = URLSession.shared
            
            let request = NSMutableURLRequest(url: url)
            
            request.httpMethod = "GET"
            request.setValue("Bearer \(auth!)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            let task = session.dataTask(with: request as URLRequest) {
                data, response, error in
                
                if error != nil {
                    print("error\(String(describing: error))")
                    let alert = UIAlertController (title: "Connection", message: error?.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction (title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    DispatchQueue.main.async {
                        self.view.isUserInteractionEnabled = true
                        self.messageFrame.removeFromSuperview()
                        self.activityIndicator.stopAnimating()
                        self.refreshControl.endRefreshing()
                    }
                    return
                }
                
                do {
                    
                    if let json = try!JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String:Any] {
                        
                        if let dataJsonE = json["error"] as? String {
                            let alert = UIAlertController(title: "Information", message: dataJsonE + "\n Logout from this app ?", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "Logout", style: .default) {
                                (action) -> Void in
                                
                                // Account Sigout
                                UserDefaults.standard.removeObject(forKey: "SavedApiToken")
                                
                                var rootVC : UIViewController?
                                rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ultraKlinLogin") as! UltraKlinLogin
                                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                appDelegate.window?.rootViewController = rootVC
                            }
                            
                            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
                                UIAlertAction in
                                NSLog("Cancel Pressed")
                            }
                            
                            alert.addAction(okAction)
                            alert.addAction(cancelAction)
                            self.present(alert, animated: true, completion: nil)
                            
                            DispatchQueue.main.async {
                                // Stop Refresh =================
                                self.view.isUserInteractionEnabled = true
                                self.messageFrame.removeFromSuperview()
                                self.activityIndicator.stopAnimating()
                                self.refreshControl.endRefreshing()
                            }
                            
                        } else {
                            
                            self.pageNo = json["current_page"] as! Int
                            self.pagelimit = json["last_page"] as! Int
                            
                            let jsonItemHistory = json["data"] as! NSArray
                            
                            DispatchQueue.main.async {
                                
                                self.historyOrder.removeAll()
                                
                                for listItemLaundry in jsonItemHistory {
                                    
                                    let package_id = (listItemLaundry as AnyObject)["package_id"] as! String
                                    let produk = (listItemLaundry as AnyObject)["code"] as! String
                                    let status = (listItemLaundry as AnyObject)["status"] as! String
                                    let date = (listItemLaundry as AnyObject)["date"] as! String
                                    
                                    if package_id == "1" {
                                        self.historyOrder.append(MyHistory(imageHistory:#imageLiteral(resourceName: "historyC"),produk: produk, status: status, date: date))
                                    } else {
                                        self.historyOrder.append(MyHistory(imageHistory:#imageLiteral(resourceName: "historyL"),produk: produk, status: status, date: date))
                                    }
                                }
                                if jsonItemHistory.count == 0 {
                                    self.tableHistoryOrderCustomers.separatorStyle = .none
                                } else if self.pagelimit == 1 {
                                    self.tableHistoryOrderCustomers.separatorStyle = .singleLine
                                } else {
                                    let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(UltraKlinHistoryView.swipedTouch))
                                    swipeRight.direction = UISwipeGestureRecognizerDirection.right
                                    self.tableHistoryOrderCustomers.addGestureRecognizer(swipeRight)
                                    
                                    let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(UltraKlinHistoryView.swipedTouch))
                                    swipeLeft.direction = UISwipeGestureRecognizerDirection.left
                                    self.tableHistoryOrderCustomers.addGestureRecognizer(swipeLeft)
                                    
                                    self.tableHistoryOrderCustomers.separatorStyle = .singleLine
                                }
                                self.pageHistory.numberOfPages = self.pagelimit
                                self.tableHistoryOrderCustomers.reloadData()
                                // Stop Refresh ===============================
                                self.view.isUserInteractionEnabled = true
                                self.messageFrame.removeFromSuperview()
                                self.activityIndicator.stopAnimating()
                                self.refreshControl.endRefreshing()
                            }
                        }
                    }
                }
            }
            task.resume()
        }
        else {
            print("Internet Connection not Available!")
            let alert = UIAlertController (title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
            alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            self.view.isUserInteractionEnabled = true
            self.messageFrame.removeFromSuperview()
            self.activityIndicator.stopAnimating()
            self.refreshControl.endRefreshing()
        }
    }
    
    func loadingData() {
        messageFrame.frame = CGRect(x: 90, y: 150 , width: 50, height: 50)
        
        activityIndicator.color = UIColor.white
        messageFrame.layer.cornerRadius = 10
        messageFrame.backgroundColor = UIColor.black
        messageFrame.alpha = 0.7
        activityIndicator.frame = CGRect(x: 90, y: 150, width: 40, height: 40)
        
        messageFrame.addSubview(activityIndicator)
        messageFrame.center = self.view.center
        activityIndicator.center = self.view.center
        view.addSubview(messageFrame)
        view.addSubview(activityIndicator)
        
        self.view.isUserInteractionEnabled = false
        self.activityIndicator.startAnimating()
    }
}
