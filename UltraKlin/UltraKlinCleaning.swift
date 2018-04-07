//
//  UltraKlinCleaningView.swift
//  UltraKlin
//
//  Created by Lini on 23/02/18.
//  Copyright © 2018 PT Lintas Insan Nur Inspira. All rights reserved.
//

import UIKit
import LocationPicker
import CoreLocation
import MapKit
import Foundation

extension UIButton {
    func pulsate() {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.3
        pulse.fromValue = 0.95
        pulse.toValue = 1.0
        pulse.autoreverses = true
        pulse.repeatCount = 1
        pulse.initialVelocity = 0.35
        pulse.damping = 0.5
        layer.add(pulse, forKey: "pulse")
    }
    func flash() {
        let flash = CABasicAnimation(keyPath: "opacity")
        flash.duration = 0.5
        flash.fromValue = 1
        flash.toValue = 0.1
        flash.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        flash.autoreverses = true
        flash.repeatCount = 3
        layer.add(flash, forKey: nil)
    }
    func shake() {
        let shake = CABasicAnimation(keyPath: "position")
        shake.duration = 0.1
        shake.repeatCount = 2
        shake.autoreverses = true
        let fromPoint = CGPoint(x: center.x - 5, y: center.y)
        let fromValue = NSValue(cgPoint: fromPoint)
        let toPoint = CGPoint(x: center.x + 5, y: center.y)
        let toValue = NSValue(cgPoint: toPoint)
        shake.fromValue = fromValue
        shake.toValue = toValue
        layer.add(shake, forKey: "position")
    }
}

extension UIView {
    // Border Bottom
    func addBottomBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = UIColor.lightGray.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: frame.size.width, height: width)
        self.layer.addSublayer(border)
    }
}

class UltraKlinCleaning: UIViewController, UITextFieldDelegate {
    
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
    var total          : Int = 0
    var amountBed      = ""
    var amountBath     = ""
    var amountOther    = ""
    var promo          = ""
    var paramString    = ""
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
    @IBOutlet weak var textPromoCode: CustomUITextField!
    
    // Scroll View
    @IBOutlet weak var scrollViewCleaning: UIScrollView!
    
    // View
    @IBOutlet weak var viewRoomType: UIView!
    @IBOutlet weak var viewAditional: UIView!
    @IBOutlet weak var viewDestinational: UIView!
    @IBOutlet weak var viewPromoCode: UIView!
    @IBOutlet weak var viewNextButtom: UIView!
    
    // Button
    @IBOutlet weak var buttonPromoCode: UIButton!
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
    
    @IBAction func buttonPromoCode(_ sender: Any) {
        promoCleaningButton()
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
            total = (totalBath + totalBed + totalOther) * resultAddCSO
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
            resultBath = self.firstNumber + 1
        }
        labelTypeBathroom.text = "\(resultBath)"
        totalBath = resultBath * hargaBath
        total = (totalBath + totalBed + totalOther) * resultAddCSO
        estPrice = total
        labelEstimatedPrices.text = String(estPrice)
        totalJam = Float(resultBed + resultBath + resultOther) * 0.5
        labelEstimatedTime.text = "\(Float(totalJam))"+" "+"Hours"
    }
    
    @IBAction func buttonMinBathroom(_ sender: Any) {
        isTypingNumber = false
        firstNumber    = Int(labelTypeBathroom.text!)!
        if Int(labelTypeBathroom.text!)! == 0 {
            
        } else {
            resultBath = self.firstNumber - 1
        }
        labelTypeBathroom.text = "\(resultBath)"
        totalBath = resultBath * hargaBath
        total = (totalBath + totalBed + totalOther) * resultAddCSO
        estPrice = total
        labelEstimatedPrices.text = String(estPrice)
        totalJam = Float(resultBed + resultBath + resultOther) * 0.5
        labelEstimatedTime.text = "\(Float(totalJam))"+" "+"Hours"
    }
    
    @IBAction func buttonPlusBedroom(_ sender: Any) {
        isTypingNumber = false
        firstNumber    = Int(labelTypeBedroom.text!)!
        if Int(labelTypeBedroom.text!)! >= 0 {
            resultBed = self.firstNumber + 1
        }
        labelTypeBedroom.text = "\(resultBed)"
        totalBed = resultBed * hargaBed
        total = (totalBath + totalBed + totalOther) * resultAddCSO
        estPrice = total
        labelEstimatedPrices.text = String(estPrice)
        totalJam = Float(resultBed + resultBath + resultOther) * 0.5
        labelEstimatedTime.text = "\(Float(totalJam))"+" "+"Hours"
    }
    
    @IBAction func buttonMinBedroom(_ sender: Any) {
        isTypingNumber = false
        firstNumber    = Int(labelTypeBedroom.text!)!
        if Int(labelTypeBedroom.text!)! == 0 {
            
        } else {
            resultBed = self.firstNumber - 1
        }
        labelTypeBedroom.text = "\(resultBed)"
        totalBed = resultBed * hargaBed
        total = (totalBath + totalBed + totalOther) * resultAddCSO
        estPrice = total
        labelEstimatedPrices.text = String(estPrice)
        totalJam = Float(resultBed + resultBath + resultOther) * 0.5
        labelEstimatedTime.text = "\(Float(totalJam))"+" "+"Hours"
    }
    
    @IBAction func buttonPlusOtherroom(_ sender: Any) {
        isTypingNumber = false
        firstNumber    = Int(labelTypeOtherroom.text!)!
        if Int(labelTypeOtherroom.text!)! >= 0 {
            resultOther = self.firstNumber + 1
        }
        labelTypeOtherroom.text = "\(resultOther)"
        totalOther = resultOther * hargaOther
        total = (totalBath + totalBed + totalOther) * resultAddCSO
        estPrice = total
        labelEstimatedPrices.text = String(estPrice)
        totalJam = Float(resultBed + resultBath + resultOther) * 0.5
        labelEstimatedTime.text = "\(Float(totalJam))"+" "+"Hours"
    }
    
    @IBAction func buttonMinOtherroom(_ sender: Any) {
        isTypingNumber = false
        firstNumber    = Int(labelTypeOtherroom.text!)!
        if Int(labelTypeOtherroom.text!)! == 0 {
            
        } else {
            resultOther = self.firstNumber - 1
        }
        labelTypeOtherroom.text = "\(resultOther)"
        totalOther = resultOther * hargaOther
        total = (totalBath + totalBed + totalOther) * resultAddCSO
        estPrice = total
        labelEstimatedPrices.text = String(estPrice)
        totalJam = Float(resultBed + resultBath + resultOther) * 0.5
        labelEstimatedTime.text = "\(Float(totalJam))"+" "+"Hours"
    }
    
    @IBAction func buttonCleaningNext(_ sender: Any) {
        self.jam         = String(totalJam)
        self.amountBath  = String(resultBath)
        self.amountBed   = String(resultBed)
        self.amountOther = String(resultOther)
        let pDate        = self.textMyDate.text
        let pTime        = self.textMyTime.text
        promo            = textPromoCode.text!
        
        let defaults = UserDefaults.standard
        
        totalFix = total
        
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
                
            } else if labelPickerPlaces.text == "No location selected" {
                
                let alert = UIAlertController (title: "Deliver Place", message: "Please select your location.", preferredStyle: .alert)
                alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            } else {
                if textPromoCode.text == "" {
                    self.performSegue(withIdentifier: "informationComplate", sender: self)
                } else {
                    loadingData()
                    print("******* ada promo")
                    
                    paramString = "&total=" + String(total) + "&amount_bath=" + labelTypeBathroom.text! + "&amount_bed=" + labelTypeBedroom.text! + "&amount_other=" + labelTypeOtherroom.text! + "&date=" + textMyDate.text! + "&time=" + textMyTime.text! + "&promo=" + textPromoCode.text! + "&name=Cleaning Service"
                    
                    let url = NSURL(string: Config().URL_Cleaning_Promo)!
                    let session = URLSession.shared
                    
                    let request = NSMutableURLRequest(url: url as URL)
                    
                    request.httpMethod = "POST"
                    request.httpBody = paramString.data(using: String.Encoding.utf8)
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
                                
                                self.textPromoCode.backgroundColor = #colorLiteral(red: 0.007649414241, green: 0.680324614, blue: 0.8433994055, alpha: 1)
                                self.textPromoCode.textColor = UIColor.white
                                
                                self.view.isUserInteractionEnabled = true
                                self.messageFrame.removeFromSuperview()
                                self.activityIndicator.stopAnimating()
                                self.refreshControl.endRefreshing()
                                
                                self.performSegue(withIdentifier: "informationComplate", sender: self)
                            }
                        }
                        print("******* response = \(data!)")
                    }
                    task.resume()
                }
            }
        }
        
        defaults.set(amountBath, forKey: "amount_bath")
        defaults.set(amountBed, forKey: "amount_bed")
        defaults.set(amountOther, forKey: "amount_other")
        defaults.set(pDate!, forKey: "date")
        defaults.set(pTime!, forKey: "time")
        defaults.set(promo, forKey: "code")
        defaults.set(address, forKey: "address")
        defaults.set(selectPlaces, forKey: "building")
        defaults.set(chooceCSO, forKey: "gender")
        defaults.set(chooceHavePet, forKey: "pet")
        defaults.set(jam, forKey: "estimated")
        defaults.set(total, forKey: "estimatedPrice")
        defaults.set(resultAddCSO, forKey: "qtyCSO")
        defaults.set(totalFix, forKey: "total")
        defaults.synchronize()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonNextAnimation.isEnabled = true
        self.textPromoCode.delegate = self
        self.viewLayoutCleaningStyle()
        self.pickerViewPlaces()
        self.createDatePicker()
        self.createTimePicker()
        self.location = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        labelRoomType.addBottomBorderWithColor(color: UIColor.lightGray, width: 1)
        labelAditional.addBottomBorderWithColor(color: UIColor.lightGray, width: 1)
        labelDestination.addBottomBorderWithColor(color: UIColor.lightGray, width: 1)
        labelPromoCode.addBottomBorderWithColor(color: UIColor.lightGray, width: 1)
    }
    
    var location: Location? {
        didSet {
            labelPickerPlaces.text = location.flatMap({ $0.title }) ?? "No location selected"
            address = String(labelPickerPlaces.text!)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(segue.identifier as Any)
        if segue.identifier == "LocationPickerCleaning" {
            let locationPicker = segue.destination as! LocationPickerViewController
            locationPicker.location = location
            locationPicker.showCurrentLocationButton = true
            locationPicker.useCurrentLocationAsHint = true
            locationPicker.selectCurrentLocationInitially = true
            locationPicker.completion = { self.location = $0 }
        }
    }
    
    func promoCleaningButton() {
        let defaults = UserDefaults.standard
        if textPromoCode.text == "" {
            print("******* non promo")
            let alert = UIAlertController (title: "Promo Code", message: "Please insert code promo.", preferredStyle: .alert)
            alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else if(total < 100000) {
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
                
            paramString = "&total=" + String(total) + "&amount_bath=" + labelTypeBathroom.text! + "&amount_bed=" + labelTypeBedroom.text! + "&amount_other=" + labelTypeOtherroom.text! + "&date=" + textMyDate.text! + "&time=" + textMyTime.text! + "&promo=" + textPromoCode.text! + "&name=Cleaning Service"
                
            let url = NSURL(string: Config().URL_Cleaning_Promo)!
            let session = URLSession.shared
                
            let request = NSMutableURLRequest(url: url as URL)
                
            request.httpMethod = "POST"
            request.httpBody = paramString.data(using: String.Encoding.utf8)
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
                        
                        self.textPromoCode.backgroundColor = #colorLiteral(red: 0.007649414241, green: 0.680324614, blue: 0.8433994055, alpha: 1)
                        self.textPromoCode.textColor = UIColor.white
                        self.textPromoCode.isUserInteractionEnabled = false
                        
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
        // Style Delivery to places
        viewDestinational.backgroundColor = UIColor.white
        viewDestinational.layer.cornerRadius = 10
        viewDestinational.layer.borderWidth = 0
        viewDestinational.layer.borderColor = UIColor.lightGray.cgColor
        viewDestinational.layer.shadowColor = UIColor.lightGray.cgColor
        viewDestinational.layer.shadowOffset = CGSize(width: 0, height: 0)
        viewDestinational.layer.shadowOpacity = 1.0
        viewDestinational.layer.shadowRadius = 5.0
        viewDestinational.layer.masksToBounds = false
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
        viewNextButtom.layer.borderWidth = 1
        viewNextButtom.layer.borderColor = UIColor.lightGray.cgColor
        viewNextButtom.layer.shadowColor = UIColor.lightGray.cgColor
        viewNextButtom.layer.shadowOffset = CGSize(width: 0, height: -2)
        viewNextButtom.layer.shadowOpacity = 1.0
        viewNextButtom.layer.shadowRadius = 3
        // Style TextField Promo
        textPromoCode.layer.borderColor = #colorLiteral(red: 0.007649414241, green: 0.680324614, blue: 0.8433994055, alpha: 1)
        textPromoCode.layer.borderWidth = CGFloat(Float(1.5))
        textPromoCode.layer.cornerRadius = CGFloat(Float(5.0))
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
        if TextField == self.textPromoCode {
            self.textPromoCode.resignFirstResponder()
        }
        return true
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
