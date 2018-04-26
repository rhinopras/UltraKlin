//
//  UltraKlinLaundryDetail.swift
//  UltraKlin
//
//  Created by Lini on 20/03/18.
//  Copyright © 2018 PT Lintas Insan Nur Inspira. All rights reserved.
//
import UIKit
import Foundation
import AppsFlyerLib

class UltraKlinLaundryDetailTableCell : UITableViewCell {
    @IBOutlet weak var labelNameItem: UILabel!
    @IBOutlet weak var labelValueItem: UILabel!
}

class UltraKlinLaundryDetail: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var listChoose : [MyChoose] = []
    var kilosChoose : [MyKilos] = []
    var cleanChoose : [package_cleaning] = []
    
    var paramOrderDetail : String?
    var nameType = ""
    var itemParam = [AnyObject]()
    
    // Per Kilos
    var manyKilos : String?
    var manyKilosCloth : String?
    
    // Payment
    var dTotalCleanLD : Int = 0
    var dTotalPiece : Int?
    var dTotalKilos : Int?
    var dTotalAll : Int?
    
    // Refresh
    let messageFrame = UIView()
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    var refreshControl = UIRefreshControl()
    
    // View
    @IBOutlet weak var viewDetailLaundry: UIView!
    @IBOutlet weak var viewButtonBookLaundry: UIView!
    // Constraint List Table Item
    @IBOutlet weak var constraintListPiece: NSLayoutConstraint!
    // Service We Provide
    @IBOutlet weak var labelPerPiece: UILabel!
    @IBOutlet weak var labelPerKilos: UILabel!
    @IBOutlet weak var labelPackage: UILabel!
    @IBOutlet weak var labelService: UILabel!
    @IBOutlet weak var labelFragrance: UILabel!
    // Per Kilos
    @IBOutlet weak var labelHowManyKilos: UILabel!
    // Tabel Per Piece
    @IBOutlet weak var tableListPieceItem: UITableView!
    // Additional Information
    @IBOutlet weak var labelDatePickup: UILabel!
    @IBOutlet weak var labelTimePickup: UILabel!
    @IBOutlet weak var labelDateDeliver: UILabel!
    @IBOutlet weak var labelTimeDeliver: UILabel!
    // Detail Payment
    @IBOutlet weak var labelTotalPerPiece: UILabel!
    @IBOutlet weak var labelTotalPerKilos: UILabel!
    
    @IBAction func buttonBookLaundry(_ sender: Any) {
        self.performSegue(withIdentifier: "segueDetailOrderLaundry", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewLayoutCleaningDetailStyle()
        
        tableListPieceItem.delegate = self
        tableListPieceItem.dataSource = self
        
        if listChoose.count > 2 {
            for _ in 2..<listChoose.count{
                constraintListPiece.constant += 31
            }
        }
        
        let loadedDetailLaundry = UserDefaults.standard.array(forKey: "laundry_Detail") as? [[String: Any]]
        for item in loadedDetailLaundry! {
            // Service We Provide
            labelPerPiece.text = item["piece_YesNo"] as? String
            labelPerKilos.text = item["kilos_YesNo"] as? String
            labelPackage.text = item["package_YesNo"] as? String
            labelService.text = item["services"] as? String
            labelFragrance.text = item["fragrance"] as? String
            // Additional Information
            labelDatePickup.text = item["date_pickup"] as? String
            labelTimePickup.text = item["time_pickup"] as? String
            labelDateDeliver.text = item["date_deliver"] as? String
            labelTimeDeliver.text = item["time_deliver"] as? String
        }
        // Per Kilos
        labelHowManyKilos.text = manyKilos
        // Payment
        labelTotalPerPiece.text = String(dTotalPiece!)
        labelTotalPerKilos.text = String(dTotalKilos!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(segue.identifier as Any)
        if segue.identifier == "segueDetailOrderLaundry" {
            let detail = segue.destination as! UltraKlinDetailOrder
            // Total Price
            detail.totalKilos = dTotalKilos!
            detail.totalPiece = dTotalPiece!
            detail.totalClean = dTotalCleanLD
            // Array
            detail.paramTempKilos = kilosChoose
            detail.paramTempPiece = listChoose
            detail.paramTempClean = cleanChoose
        }
    }
    
    func booking_Laundry_Ready() {
        var rootVC : UIViewController?
        
        let url = NSURL(string: Config().URL_Order)!
        let session = URLSession.shared
        
        let request = NSMutableURLRequest(url: url as URL)
        
        request.httpMethod = "POST"
        
        request.httpBody = paramOrderDetail?.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest) {
            data, response, error in
            
            let json = try!JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary
            
            if error != nil {
                print("error\(error!)")
                return
            }
            
            if let dataJsonE = json["error"] as? String {
                let alert = UIAlertController (title: "Information", message: dataJsonE, preferredStyle: .alert)
                alert.addAction(UIAlertAction (title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                DispatchQueue.main.async {
                    // Stop Refresh =================
                    self.view.isUserInteractionEnabled = true
                    self.messageFrame.removeFromSuperview()
                    self.activityIndicator.stopAnimating()
                    self.refreshControl.endRefreshing()
                }
            } else if ((json["success"] as? String) != nil)  {
                let alert = UIAlertController (title: "THANK YOU", message: "\n Your order has been processed \n Our Customer Service will get in touch with you.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default)
                {
                    (action) -> Void in
                    
                    rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabUltraKlin") as! UltraKlinTabBarView
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController = rootVC
                    
                    // Stop Refresh ===============================
                    self.view.isUserInteractionEnabled = true
                    self.messageFrame.removeFromSuperview()
                    self.activityIndicator.stopAnimating()
                    self.refreshControl.endRefreshing()
                }
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
            
        }
        task.resume()
    }
    
    func paramOrderLaundry() {
        
        if labelPerPiece.text == "Yes" {
            if labelPerKilos.text == "Yes" {
                AppsFlyerTracker.shared().trackEvent(AFEventPurchase, withValues: [
                    "Laundry Pieces dan Kilos" : "Laundry Pieces dan Kilos"
                    ]);
                // Parameter ON PIECES AND KILOS =============================
                itemParam.removeAll()
                for i in 0..<listChoose.count{
                    var valitem = ""
                    let kutip = "\""
                    valitem = "{" + kutip + "id" + kutip + ":" + kutip + "\(self.listChoose[i].id)" + kutip + "," + kutip + "quantity" + kutip + ":" + "\(self.listChoose[i].qty)" + "}"
                    itemParam.append(valitem as AnyObject)
                    print(itemParam)
                    valitem.removeAll()
                }
                let apiKey = (UserDefaults.standard.string(forKey: "SavedApiKey"))
                paramOrderDetail = "&apiKey=" + apiKey! + "&name=Laundry PiecesKilos" + "&date_pickup=" + labelDatePickup.text! + "&time_pickup=" + labelTimePickup.text! + "&address=&services=" + labelService.text! + "&fragrance=" + labelFragrance.text! + "&listSatuan=\(itemParam)" + "&estimateWeight=" + labelHowManyKilos.text! +  "&listKiloan=" + labelHowManyKilos.text! + "&promo=&os=IOS" + "&version=" + String(Bundle.main.releaseVersionNumber!)
            } else {
                AppsFlyerTracker.shared().trackEvent(AFEventPurchase, withValues: [
                    "Laundry Pieces" : "Laundry Pieces"
                    ]);
                // Parameter ON PIECES =======================================
                itemParam.removeAll()
                for i in 0..<listChoose.count{
                    var valitem = ""
                    let kutip = "\""
                    valitem = "{" + kutip + "id" + kutip + ":" + kutip + "\(self.listChoose[i].id)" + kutip + "," + kutip + "quantity" + kutip + ":" + "\(self.listChoose[i].qty)" + "}"
                    itemParam.append(valitem as AnyObject)
                    print(itemParam)
                    valitem.removeAll()
                }
                let apiKey = (UserDefaults.standard.string(forKey: "SavedApiKey"))
                paramOrderDetail = "&apiKey=" + apiKey! + "&name=Laundry Pieces" + "&date_pickup=" + labelDatePickup.text! + "&time_pickup=" + labelTimePickup.text! + "&address=&services=" + labelService.text! + "&fragrance=" + labelFragrance.text! + "&listSatuan=\(itemParam)" + "&promo=&os=IOS" + "&version=" + String(Bundle.main.releaseVersionNumber!)
                
            }
        } else {
            AppsFlyerTracker.shared().trackEvent(AFEventPurchase, withValues: [
                "Laundry Kilos" : "Laundry Kilos"
                ]);
            // Parameter ON KILOS =========================================
            let apiKey = (UserDefaults.standard.string(forKey: "SavedApiKey"))
            paramOrderDetail = "&apiKey=" + apiKey! + "&name=Laundry Kilos" + "&date_pickup=" + labelDatePickup.text! + "&time_pickup=" + labelTimePickup.text! + "&address=&services=" + labelService.text! + "&fragrance=" + labelFragrance.text! + "&estimateWeight=" + labelHowManyKilos.text! + "&listKiloan=" + labelHowManyKilos.text! + "&promo=&os=IOS" + "&version=" + String(Bundle.main.releaseVersionNumber!)
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
    
    internal func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listChoose.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemDetailLaundry", for: indexPath) as! UltraKlinLaundryDetailTableCell
        cell.labelNameItem.text = listChoose[indexPath.row].name + " " + String(listChoose[indexPath.row].price)
        cell.labelValueItem.text = String(listChoose[indexPath.row].qty)
        return cell
    }
    
    func viewLayoutCleaningDetailStyle() {
        // Style Detail Information
        viewDetailLaundry.backgroundColor = UIColor.white
        viewDetailLaundry.layer.cornerRadius = 5
        viewDetailLaundry.layer.borderWidth = 0
        viewDetailLaundry.layer.borderColor = UIColor.lightGray.cgColor
        viewDetailLaundry.layer.shadowColor = UIColor.lightGray.cgColor
        viewDetailLaundry.layer.shadowOffset = CGSize(width: 0, height: 0)
        viewDetailLaundry.layer.shadowOpacity = 1.0
        viewDetailLaundry.layer.shadowRadius = 5.0
        viewDetailLaundry.layer.masksToBounds = false
        // Style View Button Next
        viewButtonBookLaundry.layer.borderWidth = 1
        viewButtonBookLaundry.layer.borderColor = UIColor.lightGray.cgColor
        viewButtonBookLaundry.layer.shadowColor = UIColor.lightGray.cgColor
        viewButtonBookLaundry.layer.shadowOffset = CGSize(width: 0, height: -2)
        viewButtonBookLaundry.layer.shadowOpacity = 1.0
        viewButtonBookLaundry.layer.shadowRadius = 3
    }
}
