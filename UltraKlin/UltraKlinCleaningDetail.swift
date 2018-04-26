//
//  UltraKlinCleaningDetail.swift
//  UltraKlin
//
//  Created by Lini on 26/02/18.
//  Copyright © 2018 PT Lintas Insan Nur Inspira. All rights reserved.
//

import UIKit
import Foundation
import AppsFlyerLib

class UltraKlinCleaningDetail: UIViewController {
    
    var paramOrder = ""
    
    // Total Price
    var totalClean : Int = 0
    var totalPieceDC : Int = 0
    var totalKilosDC : Int = 0
    
    var dataArrayClean : [package_cleaning] = []
    var dataArrayPiece : [MyChoose] = []
    var dataArrayKilos : [MyKilos] = []
    
    // Refresh
    let messageFrame = UIView()
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    var refreshControl = UIRefreshControl()
    
//    let pDate       = (UserDefaults.standard.string(forKey: "clean_Date"))
//    let pTime       = (UserDefaults.standard.string(forKey: "clean_Time"))
//    let building    = (UserDefaults.standard.string(forKey: "clean_building"))
//    let gender      = (UserDefaults.standard.string(forKey: "clean_gender"))
//    let qtycso      = (UserDefaults.standard.string(forKey: "clean_qtyCSO"))
//    let pet         = (UserDefaults.standard.string(forKey: "clean_pet"))
//    let jam         = (UserDefaults.standard.string(forKey: "clean_estTime"))
    
    @IBOutlet weak var labelBookBedroom: UILabel!
    @IBOutlet weak var labelBookBathroom: UILabel!
    @IBOutlet weak var labelBookOtherroom: UILabel!
    @IBOutlet weak var labelBookEstTime: UILabel!
    @IBOutlet weak var labelBookBuilding: UILabel!
    @IBOutlet weak var labelBookDate: UILabel!
    @IBOutlet weak var labelBookTime: UILabel!
    @IBOutlet weak var labelBookCSOGender: UILabel!
    @IBOutlet weak var labelQtyCSO: UILabel!
    @IBOutlet weak var labelBookPet: UILabel!
    @IBOutlet weak var labelBookEstPrice: UILabel!
    @IBOutlet weak var buttonBookCleaning: UIButton!
    
    @IBOutlet weak var viewDetailBg: UIView!
    @IBOutlet weak var viewButtonBook: UIView!

    @IBAction func buttonBook(_ sender: Any) {
        self.performSegue(withIdentifier: "segueDetailOrderCleaning", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(segue.identifier as Any)
        if segue.identifier == "segueDetailOrderCleaning" {
            let detail = segue.destination as! UltraKlinDetailOrder
            // Total Price
            detail.totalClean = totalClean
            detail.totalKilos = totalKilosDC
            detail.totalPiece = totalPieceDC
            
            detail.paramTempClean = dataArrayClean
            detail.paramTempPiece = dataArrayPiece
            detail.paramTempKilos = dataArrayKilos
        }
    }
    
    func actionBookCleaning() {
        if UserDefaults.standard.object(forKey: "SavedApiToken") == nil {
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
            let cancelAction = UIAlertAction(title: "Register", style: .default) {
                UIAlertAction in
                // Register
                let myVC = self.storyboard?.instantiateViewController(withIdentifier: "ultraKlinRegistration") as! UltraKlinRegistration
                myVC.skipRegis = "Regis"
                myVC.hiddenActRegis = true
                self.navigationController?.pushViewController(myVC, animated: true)
            }
            alert.addAction(cancelAction)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Ready to order", message: "Is your order complete ?", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Order", style: .default) {
                (action) -> Void in
                // READY FOR BOOKING ==========
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive) {
                UIAlertAction in
                self.buttonBookCleaning.isEnabled = true
                NSLog("Cancel Pressed")
            }
            alert.addAction(cancelAction)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func booking_Cleaning_Ready() {
        var rootVC : UIViewController?
        
        let url = NSURL(string: Config().URL_Order)!
        let session = URLSession.shared
        
        let request = NSMutableURLRequest(url: url as URL)
        
        request.httpMethod = "POST"
        request.httpBody = paramOrder.data(using: String.Encoding.utf8)
        
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
                    self.buttonBookCleaning.isEnabled = true
                }
                
            } else if ((json["success"] as? String) != nil) {
                
                let alert = UIAlertController (title: "THANK YOU", message: "\n Your order has been processed \n Our Customer Service will get in touch with you.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default)
                {
                    (action) -> Void in
                    
                    rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabUltraKlin") as! UltraKlinTabBarView
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController = rootVC
                    
                    // Stop Refresh =========================
                    self.view.isUserInteractionEnabled = true
                    self.messageFrame.removeFromSuperview()
                    self.activityIndicator.stopAnimating()
                    self.refreshControl.endRefreshing()
                    self.buttonBookCleaning.isEnabled = true
                }
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
            
        }
        task.resume()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loadedDetail = UserDefaults.standard.array(forKey: "clean_Detail") as? [[String: Any]]
        for item in loadedDetail! {
            labelQtyCSO.text         = item["clean_qtyCSO"] as? String
            labelBookBuilding.text   = item["clean_building"] as? String
            labelBookCSOGender.text  = item["clean_gender"] as? String
            labelBookEstTime.text    = item["clean_estTime"] as? String
            labelBookPet.text        = item["clean_pet"] as? String
            labelBookTime.text       = item["clean_time"] as? String
            labelBookDate.text       = item["clean_date"] as? String
        }
        buttonBookCleaning.isEnabled = true
        self.viewLayoutCleaningDetailStyle()
        labelBookEstPrice.text   = String(totalClean)
        labelBookBathroom.text   = String(dataArrayClean[0].qty!)
        labelBookBedroom.text    = String(dataArrayClean[1].qty!)
        labelBookOtherroom.text  = String(dataArrayClean[2].qty!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func viewLayoutCleaningDetailStyle() {
        // Style Detail Information
        viewDetailBg.backgroundColor = UIColor.white
        viewDetailBg.layer.cornerRadius = 5
        viewDetailBg.layer.borderWidth = 0
        viewDetailBg.layer.borderColor = UIColor.lightGray.cgColor
        viewDetailBg.layer.shadowColor = UIColor.lightGray.cgColor
        viewDetailBg.layer.shadowOffset = CGSize(width: 0, height: 0)
        viewDetailBg.layer.shadowOpacity = 1.0
        viewDetailBg.layer.shadowRadius = 5.0
        viewDetailBg.layer.masksToBounds = false
        // Style View Button Next
        viewButtonBook.layer.borderWidth = 1
        viewButtonBook.layer.borderColor = UIColor.lightGray.cgColor
        viewButtonBook.layer.shadowColor = UIColor.lightGray.cgColor
        viewButtonBook.layer.shadowOffset = CGSize(width: 0, height: -2)
        viewButtonBook.layer.shadowOpacity = 1.0
        viewButtonBook.layer.shadowRadius = 3
    }
}
