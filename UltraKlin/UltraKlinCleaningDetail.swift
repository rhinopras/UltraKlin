//
//  UltraKlinCleaningDetail.swift
//  UltraKlin
//
//  Created by Lini on 26/02/18.
//  Copyright © 2018 PT Lintas Insan Nur Inspira. All rights reserved.
//

import UIKit
import AppsFlyerLib

class UltraKlinCleaningDetail: UIViewController {
    
    var paramOrder = ""
    var datePicker = UIDatePicker()
    var timePicker = UIDatePicker()
    
    // Refresh
    let messageFrame = UIView()
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    var refreshControl = UIRefreshControl()
    
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
    @IBOutlet weak var labelBookAddress: UILabel!
    @IBOutlet weak var labelBookPromo: UILabel!
    @IBOutlet weak var labelBookEstPrice: UILabel!
    @IBOutlet weak var labelBookTotal: UILabel!
    
    @IBOutlet weak var viewDetailBg: UIView!
    @IBOutlet weak var viewButtonBook: UIView!
    
    @IBAction func buttonBook(_ sender: Any) {
        let alert = UIAlertController(title: "Ready to order", message: "Is your order complete ?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Order", style: .default) {
            (action) -> Void in
            // READY FOR BOOKING ==========
            self.loadingData()
            self.booking_Cleaning_Ready()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive) {
            UIAlertAction in
            NSLog("Cancel Pressed")
        }
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func booking_Cleaning_Ready() {
        var rootVC : UIViewController?
        
        let url = NSURL(string: Config().URL_Cleaning_Order)!
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
                // Stop Refresh =================
                self.view.isUserInteractionEnabled = true
                self.messageFrame.removeFromSuperview()
                self.activityIndicator.stopAnimating()
                self.refreshControl.endRefreshing()
            } else if ((json["success"] as? String) != nil) {
                AppsFlyerTracker.shared().trackEvent(AFEventPurchase, withValues: [
                    AFEventPurchase : "Cleaning Service"
                    ]);
                let alert = UIAlertController (title: "THANK YOU", message: "\n Your order has been processed \n Our Customer Service will get in touch with you.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default)
                {
                    (action) -> Void in
                    rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabUltraKlin") as! UltraKlinTabBarView
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController = rootVC
                    // Stop Refresh =================
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
    
    func  loadingData() {
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
        self.viewLayoutCleaningDetailStyle()
        
        let total       = (UserDefaults.standard.string(forKey: "total"))
        let amountBath  = (UserDefaults.standard.string(forKey: "amount_bath"))
        let amountBed   = (UserDefaults.standard.string(forKey: "amount_bed"))
        let amountOther = (UserDefaults.standard.string(forKey: "amount_other"))
        var pDate       = (UserDefaults.standard.string(forKey: "date"))
        var pTime       = (UserDefaults.standard.string(forKey: "time"))
        let promo       = (UserDefaults.standard.string(forKey: "code"))
        let building    = (UserDefaults.standard.string(forKey: "building"))
        let address     = (UserDefaults.standard.string(forKey: "address"))
        let gender      = (UserDefaults.standard.string(forKey: "gender"))
        let qtycso      = (UserDefaults.standard.string(forKey: "qtyCSO"))
        let pet         = (UserDefaults.standard.string(forKey: "pet"))
        let apiKey      = (UserDefaults.standard.string(forKey: "SavedApiKey"))
        let jam         = (UserDefaults.standard.string(forKey: "estimated"))
        let estPrice    = (UserDefaults.standard.string(forKey: "estimatedPrice"))
        
        labelBookEstPrice.text      = estPrice
        labelBookBuilding.text      = building
        labelBookAddress.text         = address
        labelBookCSOGender.text         = gender
        labelBookEstTime.text    = jam! + " " + "Hours"
        labelBookPet.text       = pet
        labelBookTotal.text      = total
        labelBookPromo.text       = promo
        labelBookBedroom.text       = amountBed!
        labelBookBathroom.text      = amountBath!
        labelBookOtherroom.text     = amountOther!
        labelQtyCSO.text           = qtycso
        labelBookTime.text         = pTime
        let timeformatter = DateFormatter()
        timeformatter.timeStyle = .short
        timeformatter.dateFormat = "HH:mm"
        pTime = timeformatter.string(from: timePicker.date)
        labelBookDate.text     = pDate
        let dateFormatter     = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.dateFormat = "dd-MM-yyyy"
        pDate = dateFormatter.string(from: datePicker.date)
        
        paramOrder = "&apiKey=" + apiKey! + "&note=tidak ada" + "&address=" + address! + "&amount_bath=" + amountBath! + "&amount_bed=" + amountBed! + "&amount_other=" + amountOther! + "&typeGedung=" + building! + "&promo=" + promo! + "&gender=" + gender! + "&pet=" + pet! + "&date=" + pDate! + "&time=" + pTime! + "&total_cso=" + qtycso! + "&name=Cleaning Service" + "&os=IOS" + "&version=" + String(Bundle.main.releaseVersionNumber!)
        print(paramOrder)
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
