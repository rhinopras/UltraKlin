//
//  UltraKlinCleaningView.swift
//  UltraKlin
//
//  Created by Lini on 23/02/18.
//  Copyright © 2018 PT Lintas Insan Nur Inspira. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation

extension UIView {
    // Border Bottom
    func addBottomBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = UIColor.lightGray.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: frame.size.width, height: width)
        self.layer.addSublayer(border)
    }
}

struct package_cleaning {
    var id : Int?
    var name : String?
    var price : String?
    var qty : Int?
}

class UltraKlinCleaning: UIViewController, UITextFieldDelegate {
    
    // Package Cleaning
    var cleaning_dimanis : [package_cleaning] = []
    var kilos_dinamis : [MyKilos] = []
    var piece_dinamis : [MyChoose] = []
    
    // Time Picker
    var timePickerView = UIPickerView()
    var timeVal : [String] = ["08:00","08:30","09:00","09:30","10:00","10.30","11:00","11:30",
                              "12:00","12:30","13:00","13:30","14:00","14:30","15:00","15:30",
                              "16:00","16:30","17:00","17:30","18:00","18:30","19:00"]
    
    // Variable Type Room
    var typePlaceSelect = ["Home","Apartement","Office"]
    
    var selectedPickerPlace = UIPickerView()
    var selectPlaces : String = "Home"
    
    var promoAction = "inValid"
    var isTypingNumber = false
    var firstNumber    = 0
    var operation      = ""
    var operationBed   = ""
    var hargaBath      = 25000
    var hargaBed       = 25000
    var hargaOther     = 25000
    var totalPayment   = 0
    var resultBath     = 0
    var resultBed      = 0
    var resultOther    = 0
    var resultAddCSO   = 1
    var totalBath      = 0
    var totalBed       = 0
    var totalOther     = 0
    var totalJam       : Float = 0
    var jam            = ""
    var address        = ""
    
    // Total Price
    var total       : Int = 0
    var totalPieceC : Int = 0
    var totalKilosC : Int = 0
    
    var amountBed      = ""
    var amountBath     = ""
    var amountOther    = ""
    var promo          = ""
    var paramString = [String]()
    var totalFix       : Int = 0
    var estPrice       : Int = 0
    
    // Variable Time
    var msTime = ""
    var timePicker = UIDatePicker()
    
    // Variable Date
    var msDate = ""
    var datePicker = UIDatePicker()
    
    // Variable Segment
    var chooceCSO = "Man"
    var chooceHavePet = "Yes"
    
    // Refresh
    let messageFrame = UIView()
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    var refreshControl = UIRefreshControl()
    
    // Label
    @IBOutlet weak var labelRoomType: UILabel!
    @IBOutlet weak var labelAditional: UILabel!
    @IBOutlet weak var labelDestination: UILabel!
    @IBOutlet weak var labelPromoCode: UILabel!
    
    // Label Action Value
    @IBOutlet weak var labelPickerPlaces: UILabel!
    @IBOutlet weak var labelTypeBathroom: UILabel!
    @IBOutlet weak var labelTypeBedroom: UILabel!
    @IBOutlet weak var labelTypeOtherroom: UILabel!
    @IBOutlet weak var labelAddCSO: UILabel!
    @IBOutlet weak var labelEstimatedTime: UILabel!
    @IBOutlet weak var labelEstimatedPrices: UILabel!
    
    // TextField
    @IBOutlet weak var textTypePlace: CustomUITextField!
    @IBOutlet weak var textMyDate: CustomUITextField!
    @IBOutlet weak var textMyTime: CustomUITextField!
    
    // Scroll View
    @IBOutlet weak var scrollViewCleaning: UIScrollView!
    
    // View
    @IBOutlet weak var viewRoomType: UIView!
    @IBOutlet weak var viewAditional: UIView!
    @IBOutlet weak var viewNextButtom: UIView!
    
    // Button
    @IBOutlet weak var buttonNextAnimation: UIButton!
    
    // Segment
    @IBOutlet weak var segmentCSO: UISegmentedControl!
    @IBOutlet weak var segmentHavePet: UISegmentedControl!
    
    @IBAction func segmentCsoGender(_ sender: Any) {
        if (segmentCSO.selectedSegmentIndex == 0) {
            chooceCSO = "Man";
        } else if (segmentCSO.selectedSegmentIndex == 1) {
            chooceCSO = "Woman";
        } else if (segmentCSO.selectedSegmentIndex == 2) {
            chooceCSO = "Any";
        }
    }
    
    @IBAction func segmentPet(_ sender: Any) {
        if (segmentHavePet.selectedSegmentIndex == 0) {
            chooceHavePet = "Yes";
        }
        else if (segmentHavePet.selectedSegmentIndex == 1) {
            chooceHavePet = "No";
        }
    }
    
    @IBAction func buttonPlusAddCSO(_ sender: Any) {
        if (total < 100000) {
            self.view.isUserInteractionEnabled = true
            self.messageFrame.removeFromSuperview()
            self.activityIndicator.stopAnimating()
            self.refreshControl.endRefreshing()
            let alert = UIAlertController (title: "Information", message: "Minimum order Rp 100.000", preferredStyle: .alert)
            alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            isTypingNumber = false
            firstNumber    = Int(labelAddCSO.text!)!
            if Int(labelAddCSO.text!)! >= 1 {
                resultAddCSO = self.firstNumber + 1
            }
            labelAddCSO.text = "\(resultAddCSO)"
            total = (Int(cleaning_dimanis[0].price!)! + Int(cleaning_dimanis[1].price!)! + Int(cleaning_dimanis[2].price!)!) * resultAddCSO
            estPrice = total
            labelEstimatedPrices.text = String(estPrice)
        }
    }
    
    @IBAction func buttonMinAddCSO(_ sender: Any) {
        isTypingNumber = false
        firstNumber    = Int(labelAddCSO.text!)!
        if Int(labelAddCSO.text!)! == 1 {
            
        } else {
            resultAddCSO = self.firstNumber - 1
            total = (totalBath + totalBed + totalOther) * resultAddCSO
            estPrice = total
            labelEstimatedPrices.text = String(estPrice)
        }
        labelAddCSO.text = "\(resultAddCSO)"
    }
    
    @IBAction func buttonPlusBathroom(_ sender: AnyObject) {
        isTypingNumber = false
        firstNumber    = Int(labelTypeBathroom.text!)!
        if Int(labelTypeBathroom.text!)! >= 0 {
            cleaning_dimanis[0].qty = self.firstNumber + 1
        }
        labelTypeBathroom.text! = String(cleaning_dimanis[0].qty!)
        totalBath = cleaning_dimanis[0].qty! * Int(cleaning_dimanis[0].price!)!
        total = (totalBath + totalBed + totalOther) * resultAddCSO
        estPrice = total
        labelEstimatedPrices.text = String(estPrice)
        totalJam = Float(cleaning_dimanis[0].qty! + cleaning_dimanis[1].qty! + cleaning_dimanis[2].qty!) * 0.5
        labelEstimatedTime.text = "\(Float(totalJam))"+" "+"Hours"
    }
    
    @IBAction func buttonMinBathroom(_ sender: Any) {
        isTypingNumber = false
        firstNumber    = Int(labelTypeBathroom.text!)!
        if Int(labelTypeBathroom.text!)! == 0 {
            
        } else {
            cleaning_dimanis[0].qty = self.firstNumber - 1
        }
        labelTypeBathroom.text! = String(cleaning_dimanis[0].qty!)
        totalBath = cleaning_dimanis[0].qty! * Int(cleaning_dimanis[0].price!)!
        total = (totalBath + totalBed + totalOther) * resultAddCSO
        estPrice = total
        labelEstimatedPrices.text = String(estPrice)
        totalJam = Float(cleaning_dimanis[0].qty! + cleaning_dimanis[1].qty! + cleaning_dimanis[2].qty!) * 0.5
        labelEstimatedTime.text = "\(Float(totalJam))"+" "+"Hours"
    }
    
    @IBAction func buttonPlusBedroom(_ sender: Any) {
        isTypingNumber = false
        firstNumber    = Int(labelTypeBedroom.text!)!
        if Int(labelTypeBedroom.text!)! >= 0 {
            cleaning_dimanis[1].qty = self.firstNumber + 1
        }
        labelTypeBedroom.text! = String(cleaning_dimanis[1].qty!)
        totalBed = cleaning_dimanis[1].qty! * Int(cleaning_dimanis[1].price!)!
        total = (totalBath + totalBed + totalOther) * resultAddCSO
        estPrice = total
        labelEstimatedPrices.text = String(estPrice)
        totalJam = Float(cleaning_dimanis[0].qty! + cleaning_dimanis[1].qty! + cleaning_dimanis[2].qty!) * 0.5
        labelEstimatedTime.text = "\(Float(totalJam))"+" "+"Hours"
    }
    
    @IBAction func buttonMinBedroom(_ sender: Any) {
        isTypingNumber = false
        firstNumber    = Int(labelTypeBedroom.text!)!
        if Int(labelTypeBedroom.text!)! == 0 {
            
        } else {
            cleaning_dimanis[1].qty = self.firstNumber - 1
        }
        labelTypeBedroom.text! = String(cleaning_dimanis[1].qty!)
        totalBed = cleaning_dimanis[1].qty! * Int(cleaning_dimanis[1].price!)!
        total = (totalBath + totalBed + totalOther) * resultAddCSO
        estPrice = total
        labelEstimatedPrices.text = String(estPrice)
        totalJam = Float(cleaning_dimanis[0].qty! + cleaning_dimanis[1].qty! + cleaning_dimanis[2].qty!) * 0.5
        labelEstimatedTime.text = "\(Float(totalJam))"+" "+"Hours"
    }
    
    @IBAction func buttonPlusOtherroom(_ sender: Any) {
        isTypingNumber = false
        firstNumber    = Int(labelTypeOtherroom.text!)!
        if Int(labelTypeOtherroom.text!)! >= 0 {
            cleaning_dimanis[2].qty = self.firstNumber + 1
        }
        labelTypeOtherroom.text! = String(cleaning_dimanis[2].qty!)
        totalOther = cleaning_dimanis[2].qty! * Int(cleaning_dimanis[2].price!)!
        total = (totalBath + totalBed + totalOther) * resultAddCSO
        estPrice = total
        labelEstimatedPrices.text = String(estPrice)
        totalJam = Float(cleaning_dimanis[0].qty! + cleaning_dimanis[1].qty! + cleaning_dimanis[2].qty!) * 0.5
        labelEstimatedTime.text = "\(Float(totalJam))"+" "+"Hours"
    }
    
    @IBAction func buttonMinOtherroom(_ sender: Any) {
        isTypingNumber = false
        firstNumber    = Int(labelTypeOtherroom.text!)!
        if Int(labelTypeOtherroom.text!)! == 0 {
            
        } else {
            cleaning_dimanis[2].qty = self.firstNumber - 1
        }
        labelTypeOtherroom.text! = String(cleaning_dimanis[2].qty!)
        totalOther = cleaning_dimanis[2].qty! * Int(cleaning_dimanis[2].price!)!
        total = (totalBath + totalBed + totalOther) * resultAddCSO
        estPrice = total
        labelEstimatedPrices.text = String(estPrice)
        totalJam = Float(cleaning_dimanis[0].qty! + cleaning_dimanis[1].qty! + cleaning_dimanis[2].qty!) * 0.5
        labelEstimatedTime.text = "\(Float(totalJam))"+" "+"Hours"
    }
    
    @IBAction func buttonCleaningNext(_ sender: Any) {
        
        let defaults = UserDefaults.standard
        
        self.jam         = String(totalJam)
        self.amountBath  = String(resultBath)
        self.amountBed   = String(resultBed)
        self.amountOther = String(resultOther)
        let pDate        = self.textMyDate.text
        let pTime        = self.textMyTime.text
        
        if (pDate == "" || pTime == "") {
            let alert = UIAlertController (title: "Date and Time", message: "Date and Time are required", preferredStyle: .alert)
            alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        } else {
            
            let dateCurrent = NSDate()
            let dateFormatCurrent = DateFormatter()
            dateFormatCurrent.locale = NSLocale(localeIdentifier: "en_GB") as Locale
            dateFormatCurrent.dateFormat = "dd-MM-yyyy"
            let finalDateCurrent = dateFormatCurrent.string(from: dateCurrent as Date)
            let TodayDay = dateFormatCurrent.date(from: finalDateCurrent)
            
            let getDate = textMyDate.text
            let dayGetDate = dateFormatCurrent.date(from: getDate!)
            
            let calendar = Calendar.current
            
            let date1 = calendar.startOfDay(for: TodayDay!)
            let date2 = calendar.startOfDay(for: dayGetDate!)
            
            _ = Calendar.Component.day
            let components = calendar.dateComponents([.day], from: date1, to: date2)
            print(components)
            
            let timeCurrent = NSDate()
            let timeFormatCurrent = DateFormatter()
            timeFormatCurrent.locale = NSLocale(localeIdentifier: "en_GB") as Locale
            timeFormatCurrent.dateFormat = "HH:mm"
            let finaltimeCurrent = timeFormatCurrent.string(from: timeCurrent as Date)
            
            let TodayTime = timeFormatCurrent.date(from: finaltimeCurrent)
            let NewPlanTime = textMyTime.text
            let timeOff1 = "08:00"
            let timeOff2 = "19:00"
            
            let timeGetTime = timeFormatCurrent.date(from: NewPlanTime!)
            let timeGetTimeOff1 = timeFormatCurrent.date(from: timeOff1)
            let timeGetTimeOff2 = timeFormatCurrent.date(from: timeOff2)
            
            _ = NSCalendar.Unit.minute
            
            let compnentMinute = calendar.dateComponents([.minute], from: TodayTime!, to: timeGetTime!)
            let compnentHour1 = calendar.dateComponents([.minute],from: timeGetTime!, to: timeGetTimeOff1!)
            let compnentHour2 = calendar.dateComponents([.minute],from: timeGetTime!, to: timeGetTimeOff2!)
            
            if (components.day! < 0 ) {
                
                print("Date or time too old")
                let alert = UIAlertController (title: "Date", message: "Date too old.", preferredStyle: .alert)
                alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            } else if (components.day == 0 && compnentMinute.minute!  < 0 ) {
                
                let alert = UIAlertController (title: "Time", message: "Time too old.", preferredStyle: .alert)
                alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            } else if (compnentHour1.minute! > 0 ) {
                
                print("Order Time too work.")
                let alert = UIAlertController (title: "Order Time", message: "Order only at work time 08:00 - 19:00", preferredStyle: .alert)
                alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            } else if (compnentHour2.minute! < 0 ) {
                
                print("Order Time too work.")
                let alert = UIAlertController (title: "Order Time", message: "Order only at work time 08:00 - 19:00", preferredStyle: .alert)
                alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            } else if(total < 100000) {
                
                let alert = UIAlertController (title: "Information", message: "Minimum order Rp 100.000", preferredStyle: .alert)
                alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            } else if(totalJam < 2.0) {
                let alert = UIAlertController (title: "Information", message: "Minimum order 2.0 Hours", preferredStyle: .alert)
                alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            } else {
                defaults.set(amountBath, forKey: "clean_amount_bath")
                defaults.set(amountBed, forKey: "clean_amount_bed")
                defaults.set(amountOther, forKey: "clean_amount_other")
                defaults.set(pDate!, forKey: "clean_Date")
                defaults.set(pTime!, forKey: "clean_Time")
                defaults.set(selectPlaces, forKey: "clean_building")
                defaults.set(chooceCSO, forKey: "clean_gender")
                defaults.set(chooceHavePet, forKey: "clean_pet")
                defaults.set(jam, forKey: "clean_estTime")
                defaults.set(resultAddCSO, forKey: "clean_qtyCSO")
                
                self.performSegue(withIdentifier: "informationComplate", sender: self)
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Kilos : \(totalKilosC) Piece : \(totalPieceC)")
        dataDinamisRequestCleaning()
        buttonNextAnimation.isEnabled = true
        self.viewLayoutCleaningStyle()
        self.pickerViewPlaces()
        self.createDatePicker()
        self.createTimePicker()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        labelRoomType.addBottomBorderWithColor(color: UIColor.lightGray, width: 1)
        labelAditional.addBottomBorderWithColor(color: UIColor.lightGray, width: 1)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(segue.identifier as Any)
        if segue.identifier == "informationComplate" {
            let detail = segue.destination as! UltraKlinCleaningDetail
            // Total Price
            detail.totalClean = total
            detail.totalKilosDC = totalKilosC
            detail.totalPieceDC = totalPieceC
            
            detail.dataArrayClean = cleaning_dimanis
            detail.dataArrayKilos = kilos_dinamis
            detail.dataArrayPiece = piece_dinamis
        }
    }
    
    func dataDinamisRequestCleaning() {
        // ======================= Date Reguler and Price Per Kilos =======================
        if Reachability.isConnectedToNetwork() {
            print("Internet Connection Available!")
            let url = URL(string: Config().URL_Package_Cleaning)!
            let session = URLSession.shared
            
            let request = NSMutableURLRequest(url: url)
            
            request.httpMethod = "GET"
            
            let task = session.dataTask(with: request as URLRequest) {
                data, response, error in
                
                if error != nil {
                    print("error\(String(describing: error))")
                    return
                }
                do {
                    if let json = try!JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? Array<Any> {
                        
                        DispatchQueue.main.async {
                            
                            for addData in json {
                                
                                let id = (addData as AnyObject)["id"] as! Int
                                let name = (addData as AnyObject)["name"] as! String
                                let price = (addData as AnyObject)["price"] as! String
                                
                                self.cleaning_dimanis.append(package_cleaning(id: id, name: name, price: price, qty: 0))
                            }
                        }
                        self.view.isUserInteractionEnabled = true
                        self.messageFrame.removeFromSuperview()
                        self.activityIndicator.stopAnimating()
                        self.refreshControl.endRefreshing()
                    }
                }
            }
            task.resume()
        } else {
            self.view.isUserInteractionEnabled = true
            self.messageFrame.removeFromSuperview()
            self.activityIndicator.stopAnimating()
            self.refreshControl.endRefreshing()
            print("Internet Connection not Available!")
        }
    }
    
    func promoCleaningButton() {
        let defaults = UserDefaults.standard
        if(total < 100000) {
            let alert = UIAlertController (title: "Information", message: "Minimum order Rp 100.000", preferredStyle: .alert)
            alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else if (textMyDate.text! == "Date" || textMyTime.text! == "Time") {
            let alert = UIAlertController (title: "Date and Time", message: "Date and Time are required", preferredStyle: .alert)
            alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            loadingData()
            print("******* ada promo")
                
            //paramString = "&total=" + String(total) + "&amount_bath=" + labelTypeBathroom.text! + "&amount_bed=" + labelTypeBedroom.text! + "&amount_other=" + labelTypeOtherroom.text! + "&date=" + textMyDate.text! + "&time=" + textMyTime.text! + "&promo=" + textPromoCode.text! + "&name=Cleaning Service"
                
            let url = NSURL(string: Config().URL_Promo)!
            let session = URLSession.shared
                
            let request = NSMutableURLRequest(url: url as URL)
                
            request.httpMethod = "POST"
            //request.httpBody = paramString.data(using: String.Encoding.utf8)
            print(paramString)
                
            let task = session.dataTask(with: request as URLRequest) {
                data, response, error in
                    
                let json = try!JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary
                    
                if let dataJson = json["error"] as? String {
                        
                    print("******* response checking = \(dataJson)")
                    let alert = UIAlertController (title: "Information", message: dataJson, preferredStyle: .alert)
                    alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                        
                    DispatchQueue.main.async() {
                        self.view.isUserInteractionEnabled = true
                        self.messageFrame.removeFromSuperview()
                        self.activityIndicator.stopAnimating()
                        self.refreshControl.endRefreshing()
                    }
                        
                } else {
                        
                    let code      = json["promo"] as! String
                    let totalInt     = json["Total Payment"] as! Int
                    
                    DispatchQueue.main.async() {
                        
                        self.promo = code
                        self.totalFix = totalInt
                        self.estPrice = self.totalFix
                        self.labelEstimatedPrices.text = String(self.estPrice)
                        defaults.set(self.totalFix, forKey: "total")
                        
                        self.view.isUserInteractionEnabled = true
                        self.messageFrame.removeFromSuperview()
                        self.activityIndicator.stopAnimating()
                        self.refreshControl.endRefreshing()
                    }
                }
                print("******* response = \(data!)")
            }
            task.resume()
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
    
    func pickerViewPlaces() {
        
        // Set Places
        selectedPickerPlace.delegate = self
        selectedPickerPlace.tintColor = UIColor.white
        selectedPickerPlace.backgroundColor = #colorLiteral(red: 0.007649414241, green: 0.680324614, blue: 0.8433994055, alpha: 1)
        
        // Set toolbar places
        let toolBarPlaces = UIToolbar()
        toolBarPlaces.isTranslucent = true
        toolBarPlaces.tintColor = UIColor.black
        toolBarPlaces.sizeToFit()
        
        // Toolbar keyboard places
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(UltraKlinCleaning.dimisKeyboard))
        toolBarPlaces.setItems([spaceButton, doneButton], animated: false)
        toolBarPlaces.isUserInteractionEnabled = true
        
        textTypePlace.inputView = selectedPickerPlace
        textTypePlace.inputAccessoryView = toolBarPlaces
    }
    
    @objc func dimisKeyboard() {
        view.endEditing(true)
    }
    
    func createDatePicker() {
        
        // Setting datePicker
        datePicker.datePickerMode = UIDatePickerMode.date
        datePicker.locale = NSLocale(localeIdentifier: "en_GB") as Locale
        datePicker.backgroundColor = #colorLiteral(red: 0.007649414241, green: 0.680324614, blue: 0.8433994055, alpha: 1)
        datePicker.setValue(UIColor.white, forKey: "textColor")
        datePicker.setValue(false, forKey: "highlightsToday")
        
        // Set toolbar
        let toolBar = UIToolbar()
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()
        
        // Adds the Buttons
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(UltraKlinCleaning.doneClickDate))
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        textMyDate.inputView = datePicker
        textMyDate.inputAccessoryView = toolBar
    }
    
    @objc func doneClickDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.dateFormat = "dd-MM-yyyy"
        textMyDate.text = dateFormatter.string(from: datePicker.date)
        view.endEditing(true)
    }
    
    func createTimePicker() {
        
        // Set Time
        timePickerView.delegate = self
        timePickerView.tintColor = UIColor.white
        timePickerView.backgroundColor = #colorLiteral(red: 0.007649414241, green: 0.680324614, blue: 0.8433994055, alpha: 1)
        
        // Setting TimePicker
//        timePicker.datePickerMode = .time
//        timePicker.locale = NSLocale(localeIdentifier: "en_GB") as Locale
//        timePicker.backgroundColor = #colorLiteral(red: 0.007649414241, green: 0.680324614, blue: 0.8433994055, alpha: 1)
//        timePicker.minuteInterval = 30
//        timePicker.setValue(UIColor.white, forKey: "textColor")
//        timePicker.setValue(false, forKey: "highlightsToday")
//        var dateComponents = DateComponents()
//        dateComponents.calendar = Calendar.current
//        let unitFlags:Set<Calendar.Component> = [
//            .hour, .day, .month,
//            .year,.minute,.hour,.second,
//            .calendar]
//        dateComponents = Calendar.current.dateComponents(unitFlags, from: timePicker.date)
//        if dateComponents.minute! > 30 {
//            dateComponents.hour! += 1
//            dateComponents.minute = 00
//        } else {
//            dateComponents.minute = 30
//        }
//        timePicker.date = dateComponents.date!
        
        // Setting toolbar
        let toolBar = UIToolbar()
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()
        
        // Add the Buttons
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(UltraKlinCleaning.doneTimeClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        textMyTime.inputView = timePickerView
        textMyTime.inputAccessoryView = toolBar
    }
    
    @objc func doneTimeClick() {
//        let timeformatter = DateFormatter()
//        timeformatter.timeStyle = .short
//        timeformatter.dateFormat = "HH:mm"
//        textMyTime.text = timeformatter.string(from: timePicker.date)
        view.endEditing(true)
    }
    
    func viewLayoutCleaningStyle() {
        // Style Room Type
        viewRoomType.backgroundColor = UIColor.white
        viewRoomType.layer.cornerRadius = 10
        viewRoomType.layer.borderWidth = 0
        viewRoomType.layer.borderColor = UIColor.lightGray.cgColor
        viewRoomType.layer.shadowColor = UIColor.lightGray.cgColor
        viewRoomType.layer.shadowOffset = CGSize(width: 0, height: 0)
        viewRoomType.layer.shadowOpacity = 1.0
        viewRoomType.layer.shadowRadius = 5.0
        viewRoomType.layer.masksToBounds = false
        // Style Aditional
        viewAditional.backgroundColor = UIColor.white
        viewAditional.layer.cornerRadius = 10
        viewAditional.layer.borderWidth = 0
        viewAditional.layer.borderColor = UIColor.lightGray.cgColor
        viewAditional.layer.shadowColor = UIColor.lightGray.cgColor
        viewAditional.layer.shadowOffset = CGSize(width: 0, height: 0)
        viewAditional.layer.shadowOpacity = 1.0
        viewAditional.layer.shadowRadius = 5.0
        viewAditional.layer.masksToBounds = false
        // Style View Button Next
        viewNextButtom.layer.borderWidth = 1
        viewNextButtom.layer.borderColor = UIColor.lightGray.cgColor
        viewNextButtom.layer.shadowColor = UIColor.lightGray.cgColor
        viewNextButtom.layer.shadowOffset = CGSize(width: 0, height: -2)
        viewNextButtom.layer.shadowOpacity = 1.0
        viewNextButtom.layer.shadowRadius = 3
    }
}

extension UltraKlinCleaning: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == timePickerView {
            return timeVal.count
        } else if pickerView == selectedPickerPlace {
            return typePlaceSelect.count
        }
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == timePickerView {
            return timeVal[row]
        } else if pickerView == selectedPickerPlace {
            return typePlaceSelect[row]
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == timePickerView {
            textMyTime.text = timeVal[row]
        } else if pickerView == selectedPickerPlace {
            selectPlaces = typePlaceSelect[row]
            textTypePlace.text = selectPlaces
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var myPlaces = NSAttributedString()
        
        if pickerView == timePickerView {
            let titleDataTime = timeVal[row]
            myPlaces = NSAttributedString(string: titleDataTime, attributes: [NSAttributedStringKey.font: UIFont(name: "Arial", size: 12.0)!,NSAttributedStringKey.foregroundColor:UIColor.white])
        } else if pickerView == selectedPickerPlace {
            let titleDataPlace = typePlaceSelect[row]
            myPlaces = NSAttributedString(string: titleDataPlace, attributes: [NSAttributedStringKey.font: UIFont(name: "Arial", size: 12.0)!,NSAttributedStringKey.foregroundColor:UIColor.white])
        }
        return myPlaces
    }
}
