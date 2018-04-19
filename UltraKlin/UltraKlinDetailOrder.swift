//
//  UltraKlinDetailOrder.swift
//  UltraKlin
//
//  Created by Lini on 13/04/18.
//  Copyright © 2018 PT Lintas Insan Nur Inspira. All rights reserved.
//

import Foundation
import LocationPicker
import AppsFlyerLib

class UltraKlinDetailOrderTableCell : UITableViewCell {
    @IBOutlet weak var labelNameOrder: UILabel!
    @IBOutlet weak var labelItemOrder: UILabel!
}

class UltraKlinDetailOrder: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    fileprivate let sectionTitles = ["Cleaning", "Laundry Kilos", "Laundry Piece"]
    
    var paramTempClean : [package_cleaning] = []
    var paramTempKilos : [MyKilos] = []
    var paramTempPiece : [MyChoose] = []
    
    var createParamClean = [AnyObject]()
    
    var paramOrder : String?
    var paramPromo : String?
    var address : String?
    
    // Refresh
    let messageFrame = UIView()
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    var refreshControl = UIRefreshControl()
    
    // Cleaning
    let clean_amountBath  = (UserDefaults.standard.string(forKey: "clean_amount_bath"))
    let clean_amountBed   = (UserDefaults.standard.string(forKey: "clean_amount_bed"))
    let clean_amountOther = (UserDefaults.standard.string(forKey: "clean_amount_other"))
    let clean_Date        = (UserDefaults.standard.string(forKey: "clean_Date"))
    let clean_Time        = (UserDefaults.standard.string(forKey: "clean_Time"))
    let clean_building    = (UserDefaults.standard.string(forKey: "clean_building"))
    let clean_gender      = (UserDefaults.standard.string(forKey: "clean_gender"))
    let clean_qtycso      = (UserDefaults.standard.string(forKey: "clean_qtyCSO"))
    let clean_pet         = (UserDefaults.standard.string(forKey: "clean_pet"))
    let clean_estTime     = (UserDefaults.standard.string(forKey: "clean_estTime"))
    
    // Laundry
    let service   = (UserDefaults.standard.string(forKey: "services"))
    let fragrence = (UserDefaults.standard.string(forKey: "fragrance"))
    let datePick  = (UserDefaults.standard.string(forKey: "date_pickup"))
    let timePick  = (UserDefaults.standard.string(forKey: "time_pickup"))
    let dateDelv  = (UserDefaults.standard.string(forKey: "date_deliver"))
    let timeDelv  = (UserDefaults.standard.string(forKey: "time_deliver"))
    
    // Price Total
    var totalClean : Int = 0
    var totalPiece : Int = 0
    var totalKilos : Int = 0
    
    
    // Detail Order
    @IBOutlet weak var viewDetailOrder: UIView!
    @IBOutlet weak var labelDetailOrder: UILabel!
    @IBOutlet weak var tableDetailOrder: UITableView!
    @IBOutlet weak var constraintsDetailOrder: NSLayoutConstraint!
    
    // Deliver
    @IBOutlet weak var viewDeliverPlace: UIView!
    @IBOutlet weak var labelDeliverPlace: UILabel!
    @IBOutlet weak var labelLocation: UILabel!
    @IBOutlet weak var buttonLocation: UIButton!
    @IBAction func buttonLocationAct(_ sender: Any) {
        
    }
    
    // Note
    @IBOutlet weak var textNoteLocation: UITextField!
    @IBOutlet weak var viewNote: UIView!
    @IBOutlet weak var labelNote: UILabel!
    
    // Promo Code
    @IBOutlet weak var viewPromoCode: UIView!
    @IBOutlet weak var labelPromoCode: UILabel!
    @IBOutlet weak var textPromoCode: UITextField!
    @IBOutlet weak var buttonPromoCode: UIButton!
    @IBAction func buttonPromoCodeAct(_ sender: Any) {
        loadingData()
        createParamPromo()
    }
    
    // Button BOOK
    @IBOutlet weak var labelTotalPrice: UILabel!
    @IBOutlet weak var viewButtonBook: UIView!
    @IBOutlet weak var buttonBook: UIButton!
    @IBAction func buttonBookAct(_ sender: Any) {
        if (UserDefaults.standard.string(forKey: "SavedApiKey")) == nil && (UserDefaults.standard.string(forKey: "SessionSosmes")) == nil {
            // User not yet login ======================
            let alert = UIAlertController(title: "Login", message: "You must login first.", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Login", style: .default, handler: {(paramAction: UIAlertAction!) in
                // Login
                let myVC = self.storyboard?.instantiateViewController(withIdentifier: "ultraKlinLogin") as! UltraKlinLogin
                myVC.skipLogin = "Login"
                myVC.hiddenActLogin = true
                self.navigationController?.pushViewController(myVC, animated: true)
            })
            let cancelAction = UIAlertAction(title: "Register", style: .default, handler: {(paramAction: UIAlertAction!) in
                // Register
                let myVC = self.storyboard?.instantiateViewController(withIdentifier: "ultraKlinRegistration") as! UltraKlinRegistration
                myVC.skipRegis = "Regis"
                myVC.hiddenActRegis = true
                self.navigationController?.pushViewController(myVC, animated: true)
            })
            alert.addAction(cancelAction)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            if self.paramTempClean.isEmpty == true {
                let alert = UIAlertController(title: "UltraKlin", message: "\n Do you want else an order ?", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Order Cleaning", style: .cancel) {
                    (action) -> Void in
                    // Segue Laundry
                    self.performSegue(withIdentifier: "orderAgainCleaning", sender: self)
                }
                
                let okAction = UIAlertAction(title: "Order now", style: .default) {
                    (action) -> Void in
                    // READY FOR BOOKING ==========
                    self.corectionView()
                }
                
                alert.addAction(cancelAction)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            } else if self.paramTempPiece.isEmpty == true && self.paramTempKilos.isEmpty == true {
                let alert = UIAlertController(title: "UltraKlin", message: "\n Do you want else an order ?", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Order Laundry", style: .cancel) {
                    (action) -> Void in
                    // Segue Laundry
                    self.performSegue(withIdentifier: "orderAgainLaundry", sender: self)
                }
                
                let okAction = UIAlertAction(title: "Order now", style: .default) {
                    (action) -> Void in
                    // READY FOR BOOKING ==========
                    self.corectionView()
                }
                
                alert.addAction(cancelAction)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "Ready to order", message: "Is your order complete ?", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Order", style: .default) {
                    (action) -> Void in
                    // READY FOR BOOKING ==========
                    self.corectionView()
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive) {
                    UIAlertAction in
                    NSLog("Cancel Pressed")
                }
                alert.addAction(cancelAction)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @objc func dimisKeyboard() {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UltraKlinDetailOrder.dimisKeyboard))
        view.addGestureRecognizer(tap)
        
        var hasil : Int = 0
        print("Cleaning : \(String(totalClean)) Piece : \(String(totalPiece)) Kilos : \(String(totalKilos))")
        if paramTempClean.isEmpty == false {
            if paramTempKilos.isEmpty == false {
                if paramTempPiece.isEmpty == false {
                    if paramTempPiece.count > 1 {
                        for _ in 1..<paramTempPiece.count{
                            constraintsDetailOrder.constant += 31
                        }
                    }
                    hasil = totalClean + totalPiece + totalKilos
                    labelTotalPrice.text! = String(hasil)
                } else {
                    hasil = totalClean + totalKilos
                    labelTotalPrice.text! = String(hasil)
                }
            } else if paramTempPiece.isEmpty == false {
                if paramTempPiece.count > 2 {
                    for _ in 2..<paramTempPiece.count{
                        constraintsDetailOrder.constant += 31
                    }
                }
                hasil = totalClean + totalPiece
                labelTotalPrice.text! = String(hasil)
            } else {
                hasil = totalClean
                labelTotalPrice.text! = String(hasil)
            }
        } else {
            if paramTempKilos.isEmpty == false {
                if paramTempPiece.isEmpty == false {
                    if paramTempPiece.count > 4 {
                        for _ in 4..<paramTempPiece.count{
                            constraintsDetailOrder.constant += 31
                        }
                    }
                    hasil = totalPiece + totalKilos
                    labelTotalPrice.text! = String(hasil)
                } else {
                    hasil = totalKilos
                    labelTotalPrice.text! = String(hasil)
                }
            } else {
                if paramTempPiece.count > 5 {
                    for _ in 5..<paramTempPiece.count{
                        constraintsDetailOrder.constant += 31
                    }
                }
                hasil = totalPiece
                labelTotalPrice.text! = String(hasil)
            }
        }
        
        self.location = nil
        viewStyleItem()
        tableDetailOrder.delegate = self
        tableDetailOrder.dataSource = self
        tableDetailOrder.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        labelDetailOrder.addBottomBorderWithColor(color: UIColor.lightGray, width: 1)
        labelDeliverPlace.addBottomBorderWithColor(color: UIColor.lightGray, width: 1)
        labelNote.addBottomBorderWithColor(color: UIColor.lightGray, width: 1)
        labelPromoCode.addBottomBorderWithColor(color: UIColor.lightGray, width: 1)
    }
    
    func corectionView() {
        if labelLocation.text == "No location selected" {
            let alert = UIAlertController (title: "No location selected", message: "Please select your location.", preferredStyle: .alert)
            alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            loadingData()
            createParam()
        }
    }
    
    func createParamPromo() {
        let kutip = "\""
        var itemTempC = [AnyObject]()
        var itemTempP = [AnyObject]()
        var itemTempK = [AnyObject]()
        
        for i in 0..<paramTempClean.count{
            let addQtyCleaning = "{" + kutip + "id" + kutip + ":" + String(paramTempClean[i].id!) + "," + kutip + "quantity" + kutip + ":\(String(paramTempClean[i].qty!))}"
            itemTempC.append(addQtyCleaning as AnyObject)
        }
        
        for i in 0..<paramTempKilos.count{
            let addQtyKilos = "{" + kutip + "id" + kutip + ":" + String(paramTempKilos[i].id) + "," + kutip + "quantity" + kutip + ":\(String(paramTempKilos[i].qty))}"
            itemTempK.append(addQtyKilos as AnyObject)
        }
        
        for i in 0..<paramTempPiece.count{
            let addQtyPieces = "{" + kutip + "id" + kutip + ":" + String(paramTempPiece[i].id) + "," + kutip + "quantity" + kutip + ":\(String(paramTempPiece[i].qty))}"
            itemTempP.append(addQtyPieces as AnyObject)
        }
        
        let tempParamC = "{" + kutip + "package" + kutip + ":" + kutip + "cleaning-regular" + kutip + "," + kutip + "date" + kutip + ":" + kutip + "\(clean_Date!)" + " " + "\(clean_Time!)" + kutip + "," + kutip + "location" + kutip + ":" + kutip + labelLocation.text! + kutip + "," + kutip + "note" + kutip + ":" + kutip + textNoteLocation.text! + kutip + "," + kutip + "detail" + kutip + ": {" + kutip + "building_type" + kutip + ":" + kutip + "\(clean_building!)" + kutip + "," + kutip + "cso_gender" + kutip + ":" + kutip + "\(clean_gender!)" + kutip + "," + kutip + "total_cso" + kutip + ":" + kutip + "\(clean_qtycso!)" + kutip + "," + kutip + "pets" + kutip + ":" + kutip + "\(clean_pet!)" + kutip + "}," + kutip + "items" + kutip + ":\(itemTempC)}"
        
        let tempParamP = "{" + kutip + "package" + kutip + ":" + kutip + "laundry-pieces-regular" + kutip + "," + kutip + "date" + kutip + ":" + kutip + "\(datePick!)" + " " + "\(timePick!)" + kutip + "," + kutip + "location" + kutip + ":" + kutip + labelLocation.text! + kutip + "," + kutip + "note" + kutip + ":" + kutip + textNoteLocation.text! + kutip + "," + kutip + "detail" + kutip + ": {" + kutip + "fragrance" + kutip + ":" + kutip + "\(fragrence!)" + kutip + "," + kutip + "delivery_date" + kutip + ":" + kutip + "\(dateDelv!)" + " " + "\(timeDelv!)" + kutip + "}," + kutip + "items" + kutip + ":\(itemTempP)}"
        
        let tempParamK = "{" + kutip + "package" + kutip + ":" + kutip + "laundry-kilos-regular" + kutip + "," + kutip + "date" + kutip + ":" + kutip + "\(datePick!)" + " " + "\(timePick!)" + kutip + "," + kutip + "location" + kutip + ":" + kutip + labelLocation.text! + kutip + "," + kutip + "note" + kutip + ":" + kutip + textNoteLocation.text! + kutip + "," + kutip + "detail" + kutip + ": {" + kutip + "fragrance" + kutip + ":" + kutip + "\(fragrence!)" + kutip + "," + kutip + "delivery_date" + kutip + ":" + kutip + "\(dateDelv!)" + " " + "\(timeDelv!)" + kutip + "}," + kutip + "items" + kutip + ":\(itemTempK)}"
        
        print(tempParamC)
        print(tempParamK)
        print(tempParamP)
        
        if paramTempClean.isEmpty == false {
            if paramTempKilos.isEmpty == false {
                if paramTempPiece.isEmpty == false {
                    // Cleaning + Pieces + Kilos
                    paramPromo = "&promo=" + textPromoCode.text! + "&orders[]=" + "\(tempParamC)" + "&orders[]=" + "\(tempParamK)" + "&orders[]=" + "\(tempParamP)"
                    promo_Ready()
                } else {
                    // Cleaning + Kilos
                    paramPromo = "&promo=" + textPromoCode.text! + "&orders[]=" + "\(tempParamC)" + "&orders[]=" + "\(tempParamK)"
                    promo_Ready()
                }
            } else if paramTempPiece.isEmpty == false {
                // Cleaning + Pieces
                paramPromo = "&promo=" + textPromoCode.text! + "&orders[]=" + "\(tempParamC)" + "&orders[]=" + "\(tempParamP)"
                promo_Ready()
            } else {
                // Cleaning
                paramPromo = "&promo=" + textPromoCode.text! + "&orders[]=" + "\(tempParamC)"
                promo_Ready()
            }
        } else {
            if paramTempKilos.isEmpty == false {
                if paramTempPiece.isEmpty == false {
                    // Pieces + Kilos
                    paramPromo = "&promo=" + textPromoCode.text! + "&orders[]=" + "\(tempParamK)" + "&orders[]=" + "\(tempParamP)"
                    promo_Ready()
                } else {
                    // Kilos
                    paramPromo = "&promo=" + textPromoCode.text! + "&orders[]=" + "\(tempParamK)"
                    promo_Ready()
                }
            } else {
                // Pieces
                paramPromo = "&promo=" + textPromoCode.text! + "&orders[]=" + "\(tempParamP)"
                promo_Ready()
            }
        }
    }
    
    func createParam() {
        let kutip = "\""
        var itemTempC = [AnyObject]()
        var itemTempP = [AnyObject]()
        var itemTempK = [AnyObject]()
        
        for i in 0..<paramTempClean.count{
            let addQtyCleaning = "{" + kutip + "id" + kutip + ":" + String(paramTempClean[i].id!) + "," + kutip + "quantity" + kutip + ":\(String(paramTempClean[i].qty!))}"
            itemTempC.append(addQtyCleaning as AnyObject)
        }
        
        for i in 0..<paramTempKilos.count{
            let addQtyKilos = "{" + kutip + "id" + kutip + ":" + String(paramTempKilos[i].id) + "," + kutip + "quantity" + kutip + ":\(String(paramTempKilos[i].qty))}"
            itemTempK.append(addQtyKilos as AnyObject)
        }
        
        for i in 0..<paramTempPiece.count{
            let addQtyPieces = "{" + kutip + "id" + kutip + ":" + String(paramTempPiece[i].id) + "," + kutip + "quantity" + kutip + ":\(String(paramTempPiece[i].qty))}"
            itemTempP.append(addQtyPieces as AnyObject)
        }
        
        let tempParamC = "{" + kutip + "package" + kutip + ":" + kutip + "cleaning-regular" + kutip + "," + kutip + "date" + kutip + ":" + kutip + "\(clean_Date!)" + " " + "\(clean_Time!)" + kutip + "," + kutip + "location" + kutip + ":" + kutip + labelLocation.text! + kutip + "," + kutip + "note" + kutip + ":" + kutip + textNoteLocation.text! + kutip + "," + kutip + "detail" + kutip + ": {" + kutip + "building_type" + kutip + ":" + kutip + "\(clean_building!)" + kutip + "," + kutip + "cso_gender" + kutip + ":" + kutip + "\(clean_gender!)" + kutip + "," + kutip + "total_cso" + kutip + ":" + kutip + "\(clean_qtycso!)" + kutip + "," + kutip + "pets" + kutip + ":" + kutip + "\(clean_pet!)" + kutip + "}," + kutip + "items" + kutip + ":\(itemTempC)}"
        
        let tempParamP = "{" + kutip + "package" + kutip + ":" + kutip + "laundry-pieces-regular" + kutip + "," + kutip + "date" + kutip + ":" + kutip + "\(datePick!)" + " " + "\(timePick!)" + kutip + "," + kutip + "location" + kutip + ":" + kutip + labelLocation.text! + kutip + "," + kutip + "note" + kutip + ":" + kutip + textNoteLocation.text! + kutip + "," + kutip + "detail" + kutip + ": {" + kutip + "fragrance" + kutip + ":" + kutip + "\(fragrence!)" + kutip + "," + kutip + "delivery_date" + kutip + ":" + kutip + "\(dateDelv!)" + " " + "\(timeDelv!)" + kutip + "}," + kutip + "items" + kutip + ":\(itemTempP)}"
        
        let tempParamK = "{" + kutip + "package" + kutip + ":" + kutip + "laundry-kilos-regular" + kutip + "," + kutip + "date" + kutip + ":" + kutip + "\(datePick!)" + " " + "\(timePick!)" + kutip + "," + kutip + "location" + kutip + ":" + kutip + labelLocation.text! + kutip + "," + kutip + "note" + kutip + ":" + kutip + textNoteLocation.text! + kutip + "," + kutip + "detail" + kutip + ": {" + kutip + "fragrance" + kutip + ":" + kutip + "\(fragrence!)" + kutip + "," + kutip + "delivery_date" + kutip + ":" + kutip + "\(dateDelv!)" + " " + "\(timeDelv!)" + kutip + "}," + kutip + "items" + kutip + ":\(itemTempK)}"
        
        print(tempParamC)
        print(tempParamK)
        print(tempParamP)
        
        if paramTempClean.isEmpty == false {
            if paramTempKilos.isEmpty == false {
                if paramTempPiece.isEmpty == false {
                    // Cleaning + Pieces + Kilos
                    paramOrder = "&payment=Cash" + "&promo=" + textPromoCode.text! + "&orders[]=" + "\(tempParamC)" + "&orders[]=" + "\(tempParamK)" + "&orders[]=" + "\(tempParamP)"
                    print(paramOrder!)
                    booking_Ready()
                } else {
                    // Cleaning + Kilos
                    paramOrder = "&payment=Cash" + "&promo=" + textPromoCode.text! + "&orders[]=" + "\(tempParamC)" + "&orders[]=" + "\(tempParamK)"
                    print(paramOrder!)
                    booking_Ready()
                }
            } else if paramTempPiece.isEmpty == false {
                // Cleaning + Pieces
                paramOrder = "&payment=Cash" + "&promo=" + textPromoCode.text! + "&orders[]=" + "\(tempParamC)" + "&orders[]=" + "\(tempParamP)"
                print(paramOrder!)
                booking_Ready()
            } else {
                // Cleaning
                paramOrder = "&payment=Cash" + "&promo=" + textPromoCode.text! + "&orders[]=" + "\(tempParamC)"
                print(paramOrder!)
                booking_Ready()
            }
        } else {
            if paramTempKilos.isEmpty == false {
                if paramTempPiece.isEmpty == false {
                    // Pieces + Kilos
                    paramOrder = "&payment=Cash" + "&promo=" + textPromoCode.text! + "&orders[]=" + "\(tempParamK)" + "&orders[]=" + "\(tempParamP)"
                    print(paramOrder!)
                    booking_Ready()
                } else {
                    // Kilos
                    paramOrder = "&payment=Cash" + "&promo=" + textPromoCode.text! + "&orders[]=" + "\(tempParamK)"
                    print(paramOrder!)
                    booking_Ready()
                }
            } else {
                // Pieces
                paramOrder = "&payment=Cash" + "&promo=" + textPromoCode.text! + "&orders[]=" + "\(tempParamP)"
                print(paramOrder!)
                booking_Ready()
            }
        }
    }
    
    func booking_Ready() {
        
        let auth = UserDefaults.standard.string(forKey: "SavedApiKey")
        
        let url = NSURL(string: Config().URL_Order)!
        let session = URLSession.shared
        
        let request = NSMutableURLRequest(url: url as URL)
        
        let user_agent = "UltraKlin \(Bundle.main.releaseVersionNumber!) \(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
        
        request.httpMethod = "POST"
        request.setValue(user_agent, forHTTPHeaderField: "User-Agent")
        request.setValue("Bearer \(auth!)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        request.httpBody = paramOrder?.data(using: String.Encoding.utf8)
        
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
            } else if ((json["success"] as? String) != nil) {
                
                DispatchQueue.main.async {
                    
                    AppsFlyerTracker.shared().trackEvent(AFEventPurchase, withValues: [
                        AFEventPurchase : "Order"
                        ]);
                    
                    // Stop Refresh =========================
                    self.view.isUserInteractionEnabled = true
                    self.messageFrame.removeFromSuperview()
                    self.activityIndicator.stopAnimating()
                    self.refreshControl.endRefreshing()
                    
                    let alert = UIAlertController (title: "THANK YOU", message: "\n Your order has been processed \n Our Customer Service will get in touch with you.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default)
                    {
                        (action) -> Void in
                        
                        let rootVC : UIViewController?
                        rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabUltraKlin") as! UltraKlinTabBarView
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.window?.rootViewController = rootVC
                        
                    }
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
                
            }
            
        }
        task.resume()
    }
    
    func promo_Ready() {
        
        let url = NSURL(string: Config().URL_Promo)!
        let session = URLSession.shared
        
        let request = NSMutableURLRequest(url: url as URL)
        
        request.httpMethod = "POST"
        
        request.httpBody = paramPromo?.data(using: String.Encoding.utf8)
        
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
            } else if ((json["success"] as? String) != nil) {
                
                let discount = json["discount"] as! String
                
                DispatchQueue.main.async {
                    
                    self.labelTotalPrice.text = String((self.totalClean + self.totalPiece + self.totalKilos) - Int(discount)!)
                    self.textPromoCode.backgroundColor = #colorLiteral(red: 0.007649414241, green: 0.680324614, blue: 0.8433994055, alpha: 1)
                    self.textPromoCode.textColor = UIColor.white
                    self.textPromoCode.isUserInteractionEnabled = false
                    
                    // Stop Refresh =========================
                    self.view.isUserInteractionEnabled = true
                    self.messageFrame.removeFromSuperview()
                    self.activityIndicator.stopAnimating()
                    self.refreshControl.endRefreshing()
                    
                }
                
            }
            
        }
        task.resume()
    }
    
    // MARK:- UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.paramTempClean.count
        case 1:
            return self.paramTempKilos.count
        case 2:
            return self.paramTempPiece.count
        default:
            break
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            // Cleaning
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellDetailOrder", for: indexPath) as! UltraKlinDetailOrderTableCell
            cell.labelNameOrder.text = paramTempClean[indexPath.row].name
            cell.labelItemOrder.text = String(paramTempClean[indexPath.row].qty!)
            return cell
        case 1:
            // Laundry Kilos
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellDetailOrder", for: indexPath) as! UltraKlinDetailOrderTableCell
            cell.labelNameOrder.text = paramTempKilos[indexPath.row].name
            cell.labelItemOrder.text = String(paramTempKilos[indexPath.row].qty)
            return cell
        case 2:
            // Laundry Piece
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellDetailOrder", for: indexPath) as! UltraKlinDetailOrderTableCell
            cell.labelNameOrder.text = paramTempPiece[indexPath.row].name
            cell.labelItemOrder.text = String(paramTempPiece[indexPath.row].qty)
            return cell
        default:
            break
        }
        return tableView.dequeueReusableCell(withIdentifier: "cellDetailOrder")!
    }
    
    // MARK:- UITableViewDelegate
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionTitles[section]
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 30 : 15
    }
    
    var location: Location? {
        didSet {
            labelLocation.text = location.flatMap({ $0.title }) ?? "No location selected"
            address = String(labelLocation.text!)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(segue.identifier as Any)
        if segue.identifier == "LocationPicker" {
            let locationPicker = segue.destination as! LocationPickerViewController
            locationPicker.location = location
            locationPicker.showCurrentLocationButton = true
            locationPicker.useCurrentLocationAsHint = true
            locationPicker.selectCurrentLocationInitially = true
            locationPicker.completion = { self.location = $0 }
        } else if segue.identifier == "orderAgainLaundry" {
            let detail = segue.destination as! UltraKlinLaundry
            // Total Clean
            detail.totalCleanL = totalClean
            // Array
            detail.dataKilos = paramTempKilos
            detail.itemChoose = paramTempPiece
            detail.dataClean = paramTempClean
        } else if segue.identifier == "orderAgainCleaning" {
            let detail = segue.destination as! UltraKlinCleaning
            // Total Laundry
            detail.totalKilosC = totalKilos
            detail.totalPieceC = totalPiece
            // Array
            detail.kilos_dinamis = paramTempKilos
            detail.cleaning_dimanis = paramTempClean
            detail.piece_dinamis = paramTempPiece
        }
    }
    
    func animateTextField(TextField: UITextField, up: Bool, withOffset offset:CGFloat) {
        let movementDistance : Int = -Int(offset)
        let movementDuration : Double = 0.25
        let movement : Int = (up ? movementDistance : -movementDistance)
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: CGFloat(movement))
        UIView.commitAnimations()
    }
    
    func textFieldDidBeginEditing(_ TextField: UITextField) {
        self.animateTextField(TextField: TextField, up: true,
                              withOffset: TextField.frame.origin.y / 0.37)
    }
    
    func textFieldDidEndEditing(_ TextField: UITextField) {
        self.animateTextField(TextField: TextField, up: false,
                              withOffset: TextField.frame.origin.y / 0.37)
    }
    
    func textFieldShouldReturn(_ TextField: UITextField) -> Bool {
        if TextField == self.textNoteLocation {
            self.textNoteLocation.resignFirstResponder()
        }
        if TextField == self.textPromoCode {
            self.textPromoCode.resignFirstResponder()
        }
        return true
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
    
    func viewStyleItem() {
        // Style Detail Order
        viewDetailOrder.backgroundColor = UIColor.white
        viewDetailOrder.layer.cornerRadius = 10
        viewDetailOrder.layer.borderWidth = 0
        viewDetailOrder.layer.borderColor = UIColor.lightGray.cgColor
        viewDetailOrder.layer.shadowColor = UIColor.lightGray.cgColor
        viewDetailOrder.layer.shadowOffset = CGSize(width: 0, height: 0)
        viewDetailOrder.layer.shadowOpacity = 1.0
        viewDetailOrder.layer.shadowRadius = 5.0
        viewDetailOrder.layer.masksToBounds = false
        // Style Delivery to places
        viewDeliverPlace.backgroundColor = UIColor.white
        viewDeliverPlace.layer.cornerRadius = 10
        viewDeliverPlace.layer.borderWidth = 0
        viewDeliverPlace.layer.borderColor = UIColor.lightGray.cgColor
        viewDeliverPlace.layer.shadowColor = UIColor.lightGray.cgColor
        viewDeliverPlace.layer.shadowOffset = CGSize(width: 0, height: 0)
        viewDeliverPlace.layer.shadowOpacity = 1.0
        viewDeliverPlace.layer.shadowRadius = 5.0
        viewDeliverPlace.layer.masksToBounds = false
        // Style Note
        viewNote.backgroundColor = UIColor.white
        viewNote.layer.cornerRadius = 10
        viewNote.layer.borderWidth = 0
        viewNote.layer.borderColor = UIColor.lightGray.cgColor
        viewNote.layer.shadowColor = UIColor.lightGray.cgColor
        viewNote.layer.shadowOffset = CGSize(width: 0, height: 0)
        viewNote.layer.shadowOpacity = 1.0
        viewNote.layer.shadowRadius = 5.0
        viewNote.layer.masksToBounds = false
        // Style Promo Code
        viewPromoCode.backgroundColor = UIColor.white
        viewPromoCode.layer.cornerRadius = 10
        viewPromoCode.layer.borderWidth = 0
        viewPromoCode.layer.borderColor = UIColor.lightGray.cgColor
        viewPromoCode.layer.shadowColor = UIColor.lightGray.cgColor
        viewPromoCode.layer.shadowOffset = CGSize(width: 0, height: 0)
        viewPromoCode.layer.shadowOpacity = 1.0
        viewPromoCode.layer.shadowRadius = 5.0
        viewPromoCode.layer.masksToBounds = false
        // Style View Button Next
        viewButtonBook.layer.borderWidth = 1
        viewButtonBook.layer.borderColor = UIColor.lightGray.cgColor
        viewButtonBook.layer.shadowColor = UIColor.lightGray.cgColor
        viewButtonBook.layer.shadowOffset = CGSize(width: 0, height: -2)
        viewButtonBook.layer.shadowOpacity = 1.0
        viewButtonBook.layer.shadowRadius = 3
        // Style TextField Promo
        textPromoCode.layer.borderColor = #colorLiteral(red: 0.007649414241, green: 0.680324614, blue: 0.8433994055, alpha: 1)
        textPromoCode.layer.borderWidth = CGFloat(Float(1.5))
        textPromoCode.layer.cornerRadius = CGFloat(Float(5.0))
    }
}
