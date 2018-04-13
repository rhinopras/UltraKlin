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

class UltraKlinHistoryView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let auth = (UserDefaults.standard.string(forKey: "SavedApiKey"))
    
    var historyOrder : [MyHistory] = []
    
    // Refresh
    let messageFrame = UIView()
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableHistoryOrderCustomers: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataRequestHistory()
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
        dataRequestHistory()
        tableHistoryOrderCustomers.reloadData()
    }
    
    internal func numberOfSectionsInTableView(tableView: UITableView) -> Int {
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
        cell.labelPrices.text = historyOrder[indexPath.row].total_price
        return cell
    }
    
    func dataRequestHistory() {
        loadingData()
        // ======================== Dinamis List Item Laundry =========================
        if Reachability.isConnectedToNetwork() {
            print("Internet Connection Available!")
            let url = URL(string: Config().URL_History_Order + auth!)!
            let session = URLSession.shared
            
            let request = NSMutableURLRequest(url: url)
            
            request.httpMethod = "GET"
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
                                    
                                    let produk = (listItemLaundry as AnyObject)["produk"] as! String
                                    let status = (listItemLaundry as AnyObject)["status"] as! String
                                    let date = (listItemLaundry as AnyObject)["date"] as! String
                                    let total_price = (listItemLaundry as AnyObject)["total_price"] as! String
                                    
                                    if produk == "CLEANING" {
                                        self.historyOrder.append(MyHistory(imageHistory:#imageLiteral(resourceName: "Cleaning"),produk: produk, status: status, date: date, total_price: total_price))
                                    } else {
                                        self.historyOrder.append(MyHistory(imageHistory:#imageLiteral(resourceName: "Laundry"),produk: produk, status: status, date: date, total_price: total_price))
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
