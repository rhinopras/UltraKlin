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
    
    var listChoose = [MyChoose]()
    var paramOrderDetail = ""
    var nameType = ""
    var itemParam = [AnyObject]()
    
    // Per Kilos
    var manyKilos : String?
    var manyKilosCloth : String?
    
    // Payment
    var dPromoCode : String?
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
    @IBOutlet weak var labelHowManyCloth: UILabel!
    // Tabel Per Piece
    @IBOutlet weak var tableListPieceItem: UITableView!
    // Additional Information
    @IBOutlet weak var labelDatePickup: UILabel!
    @IBOutlet weak var labelTimePickup: UILabel!
    @IBOutlet weak var labelDateDeliver: UILabel!
    @IBOutlet weak var labelTimeDeliver: UILabel!
    // Location
    @IBOutlet weak var labelLocationSelected: UILabel!
    // Detail Payment
    @IBOutlet weak var labelPromoCode: UILabel!
    @IBOutlet weak var labelTotalPerPiece: UILabel!
    @IBOutlet weak var labelTotalPerKilos: UILabel!
    @IBOutlet weak var labelTotalFix: UILabel!
    
    @IBAction func buttonBookLaundry(_ sender: Any) {
        let alert = UIAlertController(title: "Ready to order", message: "Is your order complete ?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Order", style: .default) {
            (action) -> Void in
            // READY FOR BOOKING ==========
            self.loadingData()
            self.booking_Laundry_Ready()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive) {
            UIAlertAction in
            NSLog("Cancel Pressed")
        }
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewLayoutCleaningDetailStyle()
        
        tableListPieceItem.delegate = self
        tableListPieceItem.dataSource = self
        
        if listChoose.count > 2 {
            for _ in 2..<listChoose.count{
                constraintListPiece.constant += 44
            }
        }
        
        // Service We Provide
        labelPerPiece.text = (UserDefaults.standard.string(forKey: "piece_YesNo"))
        labelPerKilos.text = (UserDefaults.standard.string(forKey: "kilos_YesNo"))
        labelPackage.text = (UserDefaults.standard.string(forKey: "package_YesNo"))
        labelService.text = (UserDefaults.standard.string(forKey: "services"))
        labelFragrance.text = (UserDefaults.standard.string(forKey: "fragrance"))
        // Per Kilos
        labelHowManyKilos.text = manyKilos
        labelHowManyCloth.text = manyKilosCloth
        // Additional Information
        labelDatePickup.text = (UserDefaults.standard.string(forKey: "date_pickup"))
        labelTimePickup.text = (UserDefaults.standard.string(forKey: "time_pickup"))
        labelDateDeliver.text = (UserDefaults.standard.string(forKey: "date_deliver"))
        labelTimeDeliver.text = (UserDefaults.standard.string(forKey: "time_deliver"))
        // Location
        labelLocationSelected.text = (UserDefaults.standard.string(forKey: "address"))
        // Payment
        labelPromoCode.text = dPromoCode
        labelTotalPerPiece.text = String(dTotalPiece!)
        labelTotalPerKilos.text = String(dTotalKilos!)
        labelTotalFix.text = String(dTotalAll!)
        
        paramOrderLaundry()
    }
    
    func booking_Laundry_Ready() {
        var rootVC : UIViewController?
        
        let url = NSURL(string: Config().URL_Laundry_Order)!
        let session = URLSession.shared
        
        let request = NSMutableURLRequest(url: url as URL)
        
        request.httpMethod = "POST"
        
        request.httpBody = paramOrderDetail.data(using: String.Encoding.utf8)
        
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
                    valitem = "{" + kutip + "satuan_name" + kutip + ":" + kutip + "\(self.listChoose[i].satuan_name)" + kutip + "," + kutip + "satuan_value" + kutip + ":" + "\(self.listChoose[i].satuan_value)" + "," + kutip + "satuan_price" + kutip + ":" + "\(self.listChoose[i].satuan_price)" + "}"
                    print(i+1)
                    itemParam.append(valitem as AnyObject)
                    print(itemParam)
                    valitem.removeAll()
                }
                let apiKey = (UserDefaults.standard.string(forKey: "SavedApiKey"))
                paramOrderDetail = "&apiKey=" + apiKey! + "&name=Laundry PiecesKilos" + "&date_pickup=" + labelDatePickup.text! + "&time_pickup=" + labelTimePickup.text! + "&address=" + labelLocationSelected.text! + "&services=" + labelService.text! + "&fragrance=" + labelFragrance.text! + "&listSatuan=\(itemParam)" + "&estimateWeight=" + labelHowManyKilos.text! +  "&listKiloan=" + labelHowManyCloth.text! + "&promo=" + labelPromoCode.text! + "&os=IOS" + "&version=" + String(Bundle.main.releaseVersionNumber!)
            } else {
                AppsFlyerTracker.shared().trackEvent(AFEventPurchase, withValues: [
                    "Laundry Pieces" : "Laundry Pieces"
                    ]);
                // Parameter ON PIECES =======================================
                itemParam.removeAll()
                for i in 0..<listChoose.count{
                    var valitem = ""
                    let kutip = "\""
                    valitem = "{" + kutip + "satuan_name" + kutip + ":" + kutip + "\(self.listChoose[i].satuan_name)" + kutip + "," + kutip + "satuan_value" + kutip + ":" + "\(self.listChoose[i].satuan_value)" + "," + kutip + "satuan_price" + kutip + ":" + "\(self.listChoose[i].satuan_price)" + "}"
                    print(i+1)
                    itemParam.append(valitem as AnyObject)
                    print(itemParam)
                    valitem.removeAll()
                }
                let apiKey = (UserDefaults.standard.string(forKey: "SavedApiKey"))
                paramOrderDetail = "&apiKey=" + apiKey! + "&name=Laundry Pieces" + "&date_pickup=" + labelDatePickup.text! + "&time_pickup=" + labelTimePickup.text! + "&address=" + labelLocationSelected.text! + "&services=" + labelService.text! + "&fragrance=" + labelFragrance.text! + "&listSatuan=\(itemParam)" + "&promo=" + labelPromoCode.text! + "&os=IOS" + "&version=" + String(Bundle.main.releaseVersionNumber!)
            }
        } else {
            AppsFlyerTracker.shared().trackEvent(AFEventPurchase, withValues: [
                "Laundry Kilos" : "Laundry Kilos"
                ]);
            // Parameter ON KILOS =========================================
            let apiKey = (UserDefaults.standard.string(forKey: "SavedApiKey"))
            paramOrderDetail = "&apiKey=" + apiKey! + "&name=Laundry Kilos" + "&date_pickup=" + labelDatePickup.text! + "&time_pickup=" + labelTimePickup.text! + "&address=" + labelLocationSelected.text! + "&services=" + labelService.text! + "&fragrance=" + labelFragrance.text! + "&estimateWeight=" + labelHowManyKilos.text! + "&listKiloan=" + labelHowManyCloth.text! + "&promo=" + labelPromoCode.text! + "&os=IOS" + "&version=" + String(Bundle.main.releaseVersionNumber!)
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
        cell.labelNameItem.text = listChoose[indexPath.row].satuan_name + " " + String(listChoose[indexPath.row].satuan_price)
        cell.labelValueItem.text = String(listChoose[indexPath.row].satuan_value)
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
