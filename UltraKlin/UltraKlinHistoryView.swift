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
    var total_price: String
}

class UltraKlinTableHistoryOrder : UITableViewCell {
    @IBOutlet weak var imageHistory: UIImageView!
    @IBOutlet weak var labelProduk: UILabel!
    @IBOutlet weak var labelStatus: UILabel!
    @IBOutlet weak var labelPrices: UILabel!
    @IBOutlet weak var labelDate: UILabel!
}

class UltraKlinHistoryView: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    let auth = (UserDefaults.standard.string(forKey: "SavedApiKey"))
    
    var historyOrder : [MyHistory] = []
    //var current_page : Int = 0
    //var last_page : Int = 0
    
    var isDataLoading:Bool=false
    var pageNo:Int=0
    var limit:Int=0
    var offset:Int=0 //pageNo*limit
    var didEndReached:Bool=false
    
    // Refresh
    let messageFrame = UIView()
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableHistoryOrderCustomers: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableHistoryOrderCustomers.delegate = self
        tableHistoryOrderCustomers.dataSource = self
        
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.lightGray.cgColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 2.0
        self.navigationController?.navigationBar.layer.shadowOpacity = 1
        self.navigationController?.navigationBar.layer.masksToBounds = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkingSession()
        tableHistoryOrderCustomers.reloadData()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isDataLoading = false
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    }
    //Pagination
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if ((tableHistoryOrderCustomers.contentOffset.y + tableHistoryOrderCustomers.frame.size.height) >= tableHistoryOrderCustomers.contentSize.height)
        {
            if pageNo == limit {
                pageNo = 1
                isDataLoading = true
                dataRequestHistoryPage()
            } else {
                if !isDataLoading{
                    isDataLoading = true
                    self.pageNo=self.pageNo+1
                    self.offset=self.limit * self.pageNo
                    dataRequestHistoryPage()
                }
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
        cell.labelStatus.text = historyOrder[indexPath.row].status
        cell.labelDate.text = historyOrder[indexPath.row].date
        cell.labelPrices.text = "Rp. " + historyOrder[indexPath.row].total_price
        return cell
    }
    
    func checkingSession() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "SavedApiKey") == nil {
            // User not yet login ======================
            let alert = UIAlertController(title: "Login", message: "You must login first.", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Login", style: .default) {
                (action) -> Void in
                // Login
                let myVC = self.storyboard?.instantiateViewController(withIdentifier: "ultraKlinLogin") as! UltraKlinLogin
                myVC.skipLogin = "Login"
                myVC.hiddenActLogin = true
                self.navigationController?.pushViewController(myVC, animated: true)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .default) {
                UIAlertAction in
            }
            alert.addAction(cancelAction)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            dataRequestHistory()
        }
    }
    
    func dataRequestHistoryPage() {
        loadingData()
        // ======================== Dinamis List Item Laundry =========================
        if Reachability.isConnectedToNetwork() {
            print("Internet Connection Available!")
            let url = URL(string: Config().URL_History + "?page=\(pageNo)")!
            let session = URLSession.shared
            
            let request = NSMutableURLRequest(url: url)
            
            request.httpMethod = "GET"
            request.setValue("Bearer \(auth!)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            let task = session.dataTask(with: request as URLRequest) {
                data, response, error in
                
                if error != nil {
                    print("error\(String(describing: error))")
                    return
                }
                
                do {
                    
                    if let json = try!JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String:Any] {
                        
                        if let dataJsonE = json["error"] as? String {
                            let alert = UIAlertController (title: "Information", message: dataJsonE + "\n Please Logout and Login again.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction (title: "OK", style: .cancel, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            DispatchQueue.main.async {
                                // Stop Refresh =================
                                self.view.isUserInteractionEnabled = true
                                self.messageFrame.removeFromSuperview()
                                self.activityIndicator.stopAnimating()
                                self.refreshControl.endRefreshing()
                            }
                            
                        } else {
                            
                            let jsonItemHistory = json["data"] as! NSArray
                            
                            DispatchQueue.main.async {
                                
                                self.historyOrder.removeAll()
                                
                                for listItemLaundry in jsonItemHistory {
                                    
                                    let package_id = (listItemLaundry as AnyObject)["package_id"] as! String
                                    let produk = (listItemLaundry as AnyObject)["code"] as! String
                                    let status = (listItemLaundry as AnyObject)["status"] as! String
                                    let date = (listItemLaundry as AnyObject)["date"] as! String
                                    let total_price = (listItemLaundry as AnyObject)["total_price"] as! Int
                                    
                                    if package_id == "1" {
                                        self.historyOrder.append(MyHistory(imageHistory:#imageLiteral(resourceName: "historyC"),produk: produk, status: status, date: date, total_price: String(total_price)))
                                    } else {
                                        self.historyOrder.append(MyHistory(imageHistory:#imageLiteral(resourceName: "historyL"),produk: produk, status: status, date: date, total_price: String(total_price)))
                                    }
                                }
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
        }
    }
    
    func dataRequestHistory() {
        loadingData()
        // ======================== Dinamis List Item Laundry =========================
        if Reachability.isConnectedToNetwork() {
            print("Internet Connection Available!")
            let url = URL(string: Config().URL_History)!
            let session = URLSession.shared
            
            let request = NSMutableURLRequest(url: url)
            
            request.httpMethod = "GET"
            request.setValue("Bearer \(auth!)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            let task = session.dataTask(with: request as URLRequest) {
                data, response, error in
                
                if error != nil {
                    print("error\(String(describing: error))")
                    return
                }
                
                do {
                    
                    if let json = try!JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String:Any] {
                        
                        if let dataJsonE = json["error"] as? String {
                            let alert = UIAlertController (title: "Information", message: dataJsonE + "\n Please Logout and Login again.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction (title: "OK", style: .cancel, handler: nil))
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
                            self.limit = json["last_page"] as! Int
                            self.offset = json["per_page"] as! Int
                            let jsonItemHistory = json["data"] as! NSArray
                            
                            DispatchQueue.main.async {
                                
                                self.historyOrder.removeAll()
                                
                                for listItemLaundry in jsonItemHistory {
                                    
                                    let package_id = (listItemLaundry as AnyObject)["package_id"] as! String
                                    let produk = (listItemLaundry as AnyObject)["code"] as! String
                                    let status = (listItemLaundry as AnyObject)["status"] as! String
                                    let date = (listItemLaundry as AnyObject)["date"] as! String
                                    let total_price = (listItemLaundry as AnyObject)["total_price"] as! Int
                                    
                                    if package_id == "1" {
                                        self.historyOrder.append(MyHistory(imageHistory:#imageLiteral(resourceName: "historyC"),produk: produk, status: status, date: date, total_price: String(total_price)))
                                    } else {
                                        self.historyOrder.append(MyHistory(imageHistory:#imageLiteral(resourceName: "historyL"),produk: produk, status: status, date: date, total_price: String(total_price)))
                                    }
                                }
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
