//
//  UltraKlinLaundry.swift
//  UltraKlin
//
//  Created by Lini on 11/03/18.
//  Copyright © 2018 PT Lintas Insan Nur Inspira. All rights reserved.
//

import UIKit
import Foundation
import LocationPicker
import CoreLocation
import MapKit

struct MyModel {
    let item: String
    let price: Int
    var many: Int
}

struct MyChoose {
    var satuan_name: String
    var satuan_price: Int
    var satuan_value: Int
}

protocol SwiftyTableViewCellDelegate : class {
    func swiftyTableViewCellDidTapPlus(_ sender: UltraKlinLaundryTableCell)
    func swiftyTableViewCellDidTapMin(_ sender: UltraKlinLaundryTableCell)
}

class UltraKlinLaundryTableCell : UITableViewCell {
    
    @IBOutlet weak var labelAddItem: UILabel!
    @IBOutlet weak var labelActItem: UILabel!
    @IBOutlet weak var buttonPlusItem: UIButton!
    @IBOutlet weak var buttonMinItem: UIButton!
    
    weak var delegate: SwiftyTableViewCellDelegate?
    
    @IBAction func buttonPlusItem(_ sender: Any) {
        delegate?.swiftyTableViewCellDidTapPlus(self)
    }
    @IBAction func buttonMinItem(_ sender: Any) {
        delegate?.swiftyTableViewCellDidTapMin(self)
    }
}

class UltraKlinLaundry: UIViewController, UITableViewDataSource , UITableViewDelegate, UITextFieldDelegate, SwiftyTableViewCellDelegate {
    
    var constrainAdditem : Int = 0
    var totalAll : Int = 0
    var totalPiece : Int = 0
    var totalKilos : Int = 0
    var totalPromo : Int = 0
    var validPromo : String = ""
    
    // Parameter
    var paramPromo : String!
    
    // Select Service We Provide
    var selectServicePicker = UIPickerView()
    var servicePick : [String] = []
    var selectFragrancePicker = UIPickerView()
    var fragrancePick : [String] = ["Yes","No"]
    
    // Select Item Per Piece
    var selectedPickerItem = UIPickerView()
    var selectItem = ""
    var itemLaundry : [MyModel] = []
    var itemChoose : [MyChoose] = []
    var priceSelect = ""
    var itemSelect = ""
    
    // Detail Kilos
    var dinamisDateReguler : Int = 0
    var dinamisPricePerKilos : Int = 0
    
    // Location
    var address = ""
    
    // Date Pickup
    var datePickerPickup = UIDatePicker()
    var timePicker = UIDatePicker()
    
    // Loading Refresh
    let messageFrame = UIView()
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    var refreshControl = UIRefreshControl()
    
    // Items Service We Provide
    @IBOutlet weak var viewServiceWeProvide: UIView!
    @IBOutlet weak var labelServiceWeProvide: UILabel!
    @IBOutlet weak var textServiceWePro: CustomUITextField!
    @IBOutlet weak var textFragranceWePro: CustomUITextField!
    
    // Items Your Order
    @IBOutlet weak var viewYourOrder: UIView!
    @IBOutlet weak var labelYourOrder: UILabel!
    @IBOutlet weak var constrainCenter: NSLayoutConstraint!
    @IBOutlet weak var constrainTableItem: NSLayoutConstraint!
    @IBOutlet weak var constrainPerPiece: NSLayoutConstraint!
    
    // Items Per Kilos
    @IBOutlet weak var labelPerKilos: UILabel!
    @IBOutlet weak var labelHowMany: UILabel!
    @IBOutlet weak var textManyKilos: CustomUITextField!
    @IBOutlet weak var textManyKilosCloth: CustomUITextField!
    @IBOutlet weak var labelMininumOrder: UILabel!
    @IBOutlet weak var labelHowManyCloth: UILabel!
    
    // Item Per Piece
    @IBOutlet weak var textChooseItem: CustomUITextField!
    @IBOutlet weak var tebleLaundryItem: UITableView!
    @IBOutlet weak var buttonAdditems: UIButton!
    @IBOutlet weak var labelChoose: UILabel!
    @IBOutlet weak var labelPerPiece: UILabel!
    
    // Item Additional Informasi
    @IBOutlet weak var viewAdditional: UIView!
    @IBOutlet weak var labelAdditional: UILabel!
    @IBOutlet weak var labelPickup: UILabel!
    @IBOutlet weak var textDatePickup: CustomUITextField!
    @IBOutlet weak var textTimePickup: CustomUITextField!
    @IBOutlet weak var textDateDeliver: CustomUITextField!
    @IBOutlet weak var textTimeDeliver: CustomUITextField!
    
    // Item Delivery to your place
    @IBOutlet weak var viewDelivery: UIView!
    @IBOutlet weak var labelDelivery: UILabel!
    @IBOutlet weak var labelSelectLocation: UILabel!
    
    // Promo Code
    @IBOutlet weak var viewPromoCode: UIView!
    @IBOutlet weak var labelPromoCode: UILabel!
    @IBOutlet weak var textPromoCode: CustomUITextField!
    
    // View Button Next
    @IBOutlet weak var viewButtonLaundry: UIView!
    @IBOutlet weak var labelTotal: UILabel!
    
    // Swicth
    @IBOutlet weak var switchPerPieceAct: UISwitch!
    @IBOutlet weak var switchPerKilosAct: UISwitch!
    @IBOutlet weak var switchPackageAct: UISwitch!
    
    @IBAction func switchPerPieceValue(_ sender: Any) {
        if switchPerPieceAct.isOn {
            if switchPerKilosAct.isOn {
                if textManyKilos.text == "" {
                    totalKilos = 0
                } else {
                    totalKilos = Int(textManyKilos.text!)! * dinamisPricePerKilos
                }
                totalAll = totalKilos + totalPiece
                labelTotal.text = String(totalAll)
                constrainPerPiece.constant = 234
                constrainCenter.constant = CGFloat(499 + constrainAdditem)
            } else {
                totalAll = 0 + totalPiece
                labelTotal.text = String(totalAll)
                constrainPerPiece.constant = 8
                constrainCenter.constant = CGFloat(273 + constrainAdditem)
            }
            textChooseItem.isHidden = false
            tebleLaundryItem.isHidden = false
            buttonAdditems.isHidden = false
            labelChoose.isHidden = false
            labelPerPiece.isHidden = false
        } else {
            if switchPerKilosAct.isOn {
                if textManyKilos.text == "" {
                    totalKilos = 0
                } else {
                    totalKilos = Int(textManyKilos.text!)! * dinamisPricePerKilos
                }
                totalAll = totalKilos + 0
                labelTotal.text = String(totalAll)
                constrainCenter.constant = 234
            } else {
                totalAll = 0
                labelTotal.text = String(totalAll)
                constrainCenter.constant = 40
            }
            textChooseItem.isHidden = true
            tebleLaundryItem.isHidden = true
            buttonAdditems.isHidden = true
            labelChoose.isHidden = true
            labelPerPiece.isHidden = true
        }
    }
    
    @IBAction func switchPerKilosValue(_ sender: Any) {
        if switchPerKilosAct.isOn {
            if switchPerPieceAct.isOn {
                if textManyKilos.text == "" {
                    totalKilos = 0
                } else {
                    totalKilos = Int(textManyKilos.text!)! * dinamisPricePerKilos
                }
                totalAll = totalKilos + totalPiece
                labelTotal.text = String(totalAll)
                constrainPerPiece.constant = 234
                constrainCenter.constant = CGFloat(499 + constrainAdditem)
            } else {
                if textManyKilos.text == "" {
                    totalKilos = 0
                } else {
                    totalKilos = Int(textManyKilos.text!)! * dinamisPricePerKilos
                }
                totalAll = totalKilos + 0
                labelTotal.text = String(totalAll)
                constrainCenter.constant = 234
            }
            labelPerKilos.isHidden = false
            labelHowMany.isHidden = false
            textManyKilos.isHidden = false
            labelMininumOrder.isHidden = false
            labelHowManyCloth.isHidden = false
            textManyKilosCloth.isHidden = false
        } else {
            textPromoCode.text = ""
            textPromoCode.isUserInteractionEnabled = true
            textPromoCode.backgroundColor = UIColor.white
            textPromoCode.textColor = UIColor.black
            if switchPerPieceAct.isOn {
                totalAll = 0 + totalPiece
                labelTotal.text = String(totalAll)
                constrainPerPiece.constant = 8
                constrainCenter.constant = CGFloat(273 + constrainAdditem)
            } else {
                totalAll = 0
                labelTotal.text = String(totalAll)
                constrainCenter.constant = 40
            }
            labelPerKilos.isHidden = true
            labelHowMany.isHidden = true
            textManyKilos.isHidden = true
            labelMininumOrder.isHidden = true
            labelHowManyCloth.isHidden = true
            textManyKilosCloth.isHidden = true
        }
    }
    
    @IBAction func switchPackageValue(_ sender: Any) {
        if switchPackageAct.isOn {
            let alert = UIAlertController (title: "Information", message: "Coming Soon", preferredStyle: .alert)
            alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            switchPackageAct.isOn = false
        }
    }
    
    @IBAction func buttonPromoCodeAct(_ sender: Any) {
        if switchPerKilosAct.isOn {
            if switchPerPieceAct.isOn {
                self.promoCondition()
            } else {
                self.promoCondition()
            }
        } else {
            textPromoCode.text = ""
            let alert = UIAlertController (title: "Information", message: "Choose service Per Kilos", preferredStyle: .alert)
            alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func buttonNextLaundry(_ sender: Any) {
        if (!switchPerPieceAct.isOn && !switchPerKilosAct.isOn) {
            // Checking Swicth Per Piece and Kilos
            let alert = UIAlertController (title: "Service We Provide", message: "Please choose one Per Piece or Per Kilos.", preferredStyle: .alert)
            alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            if switchPerKilosAct.isOn {
                // Jika Per Kilos ON ================================================ ON KILOS
                if textManyKilos.text == "" {
                    let alert = UIAlertController (title: "Per Kilos", message: "Minimum order 3 Kg.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else if Int(textManyKilos.text!)! < 3 {
                    let alert = UIAlertController (title: "Per Kilos", message: "Minimum order 3 Kg.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else if textManyKilosCloth.text == "" {
                    let alert = UIAlertController (title: "Per Kilos", message: "How many cloth per kilos.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else if Int(textManyKilosCloth.text!)! < 1 {
                    let alert = UIAlertController (title: "Per Kilos", message: "Minimum 1 cloth.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else if switchPerPieceAct.isOn {
                    // Jika Per Piece ON ============================================ ON PIECE
                    if itemChoose.count == 0 {
                        let alert = UIAlertController (title: "Per Piece", message: "Please choose one piece.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    } else  if (textDatePickup.text == "" || textTimePickup.text == "" || textDateDeliver.text == "" || textTimeDeliver.text == "") {
                        // Checking Date Time ======================================= DATE TIME CHECK || PIECE ON - KILOS ON
                        let alert = UIAlertController (title: "Date and Time", message: "Date and Time are required.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    } else {
// =================================================================================================== CHECKING VALUE DATE TIME
                        filterDateTimeFilter()
                    }
                } else  if (textDatePickup.text == "" || textTimePickup.text == "" || textDateDeliver.text == "" || textTimeDeliver.text == "") {
                    // Checking Date Time =========================================== DATE TIME CHECK || PIECE OFF - KILOS ON
                    let alert = UIAlertController (title: "Date and Time", message: "Date and Time are required.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
// =================================================================================================== CHECKING VALUE DATE TIME
                    filterDateTimeFilter()
                }
            } else if switchPerPieceAct.isOn {
                // Jika Per Piece ON ================================================ KILOS OFF - PIECE ON
                if itemChoose.count == 0 {
                    let alert = UIAlertController (title: "Per Piece", message: "Please choose one piece.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else  if (textDatePickup.text == "" || textTimePickup.text == "" || textDateDeliver.text == "" || textTimeDeliver.text == "") {
                    // Checking Date Time =========================================== DATE TIME CHECK | PIECE ON - KILOS OFF
                    let alert = UIAlertController (title: "Date and Time", message: "Date and Time are required", preferredStyle: .alert)
                    alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
// =================================================================================================== CHECKING VALUE DATE TIME
                    filterDateTimeFilter()
                }
            }
        }
    }
    
    func filterDateTimeFilter() {
        // Filter Date Pickup
        let dateCurrent = Date()
        let dateFormatCurrent = DateFormatter()
        dateFormatCurrent.locale = NSLocale(localeIdentifier: "en_GB") as Locale
        dateFormatCurrent.dateFormat = "dd-MM-yyyy"
        
        let finalDateCurrent = dateFormatCurrent.string(from: dateCurrent)
        
        let TodayDay = dateFormatCurrent.date(from: finalDateCurrent)
        
        let getDatePickup = textDatePickup.text
        
        let dayGetDate = dateFormatCurrent.date(from: getDatePickup!)
        
        let calendar = Calendar.current
        
        let date1 = calendar.startOfDay(for: TodayDay!)
        let date2 = calendar.startOfDay(for: dayGetDate!)
        
        _ = Calendar.Component.day
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        print(components)
        
        // Filter Time Pickup
        let timeCurrent = Date()
        let timeFormatCurrent = DateFormatter()
        timeFormatCurrent.locale = NSLocale(localeIdentifier: "en_GB") as Locale
        timeFormatCurrent.dateFormat = "HH:mm"
        
        let finaltimeCurrent = timeFormatCurrent.string(from: timeCurrent)
        
        let TodayTime = timeFormatCurrent.date(from: finaltimeCurrent)
        
        let getTimePickup = textTimePickup.text
        let getTimeDeliver = textTimeDeliver.text
        let timeOff1 = "08:00"
        let timeOff2 = "19:00"
        
        let timeGetTimeP = timeFormatCurrent.date(from: getTimePickup!)
        let timeGetTimeD = timeFormatCurrent.date(from: getTimeDeliver!)
        let timeGetTimeOff1 = timeFormatCurrent.date(from: timeOff1)
        let timeGetTimeOff2 = timeFormatCurrent.date(from: timeOff2)
        
        _ = NSCalendar.Unit.minute
        
        let componentMinutePickup = calendar.dateComponents([.minute], from: TodayTime!, to: timeGetTimeP!)
        let componentMinuteDeliver = calendar.dateComponents([.minute], from: timeGetTimeP!, to: timeGetTimeD!)
        let compnentHour1 = calendar.dateComponents([.minute],from: timeGetTimeP!, to: timeGetTimeOff1!)
        let compnentHour2 = calendar.dateComponents([.minute],from: timeGetTimeP!, to: timeGetTimeOff2!)
        
        if (components.day! < 0 ) {
// Checking Date ============================================
            let alert = UIAlertController (title: "Date and Time", message: "Date Pickup too old.", preferredStyle: .alert)
            alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else if (components.day == 0 && componentMinutePickup.minute!  < 0 ) {
// Checking Time Pickup =====================================
            let alert = UIAlertController (title: "Date and Time", message: "Time Pickup too old.", preferredStyle: .alert)
            alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else if (compnentHour1.minute! > 0 ) {
// Checking Time < 08:00 =====================================
            print("Order Time too work.")
            let alert = UIAlertController (title: "Time Pickup", message: "Order only at work time 08:00 - 19:00", preferredStyle: .alert)
            alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else if (compnentHour2.minute! < 0 ) {
// Checking Time > 19:00 =====================================
            print("Order Time too work.")
            let alert = UIAlertController (title: "Time Pickup", message: "Order only at work time 08:00 - 19:00", preferredStyle: .alert)
            alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        if (componentMinuteDeliver.minute!  < 0 ) {
// Checking Time Deliver ====================================
            let alert = UIAlertController (title: "Time Deliver", message: "Time Deliver too early with Time Pickup.", preferredStyle: .alert)
            alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else if labelSelectLocation.text == "No location selected" {
            let alert = UIAlertController (title: "Deliver Place", message: "Please select your location.", preferredStyle: .alert)
            alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            if textPromoCode.text! == "" {
                OrderKilos()
                self.performSegue(withIdentifier: "infoComplete", sender: self)
            } else {
//                if switchPerKilosAct.isOn {
//                    if switchPerPieceAct.isOn {
//                        let alert = UIAlertController (title: "Promo Code", message: "Promo only Per Kilos.", preferredStyle: .alert)
//                        alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
//                        self.present(alert, animated: true, completion: nil)
//                    } else {

                        self.loadingData()
                        
                        print("ada promo")
                        
                        paramPromo = "&name=Laundry Kilos" + "&estimateWeight=" + textManyKilos.text! + "&promo=" + textPromoCode.text!
                        
                        let url = NSURL(string: Config().URL_Laundry_PromoCode)!
                        let session = URLSession.shared
                        
                        let request = NSMutableURLRequest(url: url as URL)
                        
                        request.httpMethod = "POST"
                        request.httpBody = paramPromo.data(using: String.Encoding.utf8)
                        print(paramPromo)
                        
                        let task = session.dataTask(with: request as URLRequest) {
                            data, response, error in
                            
                            let json = try!JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary
                            
                            if error != nil {
                                print(error!)
                                return
                            }
                            
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
                                
                                let subTotal = json["sub Total"] as! Int
                                let totalPay = json["Total Payment"] as! Int
                                
                                DispatchQueue.main.async() {
                                    
                                    if self.switchPerPieceAct.isOn {
                                        if self.switchPerKilosAct.isOn {
                                            self.totalPromo = totalPay
                                            self.totalAll = self.totalPromo + self.totalPiece
                                            self.labelTotal.text = String(self.totalAll)
                                            
                                            self.validPromo = "valid"
                                            self.textPromoCode.isUserInteractionEnabled = false
                                            self.textPromoCode.backgroundColor = #colorLiteral(red: 0.007649414241, green: 0.680324614, blue: 0.8433994055, alpha: 1)
                                            self.textPromoCode.textColor = UIColor.white
                                        } else {
                                            self.textPromoCode.text = ""
                                            self.textPromoCode.isUserInteractionEnabled = true
                                            self.textPromoCode.backgroundColor = UIColor.white
                                            self.textPromoCode.textColor = UIColor.black
                                            self.totalAll = self.totalPiece
                                            self.labelTotal.text = String(self.totalAll)
                                        }
                                    } else {
                                        if self.switchPerKilosAct.isOn {
                                            self.totalKilos = subTotal
                                            self.totalPromo = totalPay
                                            self.totalAll = self.totalPromo
                                            self.labelTotal.text = String(self.totalAll)
                                            
                                            self.validPromo = "valid"
                                            self.textPromoCode.isUserInteractionEnabled = false
                                            self.textPromoCode.backgroundColor = #colorLiteral(red: 0.007649414241, green: 0.680324614, blue: 0.8433994055, alpha: 1)
                                            self.textPromoCode.textColor = UIColor.white
                                        } else {
                                            self.totalAll = 0
                                            self.labelTotal.text = String(self.totalAll)
                                        }
                                    }
                                    
                                    self.OrderKilos()
                                    
                                    self.view.isUserInteractionEnabled = true
                                    self.messageFrame.removeFromSuperview()
                                    self.activityIndicator.stopAnimating()
                                    self.refreshControl.endRefreshing()
                                    
                                    self.performSegue(withIdentifier: "infoComplete", sender: self)
                                }
                                
                            }
                            print("******* response = \(data!)")
                        }
                        task.resume()
                    }
                    
//                } else {
//                    let alert = UIAlertController (title: "Information", message: "Promo only Per Kilos.", preferredStyle: .alert)
//                    alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
//                    self.present(alert, animated: true, completion: nil)
//                }
//            }
        }
    }
    
    func OrderKilos() {
        let defaults = UserDefaults.standard
        
        var perKilos = "No"
        var perPiece = "No"
        var package = "No"
        
        if switchPerKilosAct.isOn {
            perKilos = "Yes"
        }
        if switchPerPieceAct.isOn {
            perPiece = "Yes"
        }
        if switchPackageAct.isOn {
            package = "Yes"
        }
        
        // Service We Provide
        defaults.set(perKilos, forKey: "kilos_YesNo")
        defaults.set(perPiece, forKey: "piece_YesNo")
        defaults.set(package, forKey: "package_YesNo")
        defaults.set(textServiceWePro.text, forKey: "services")
        defaults.set(textFragranceWePro.text, forKey: "fragrance")
        // Date Time
        defaults.set(textDatePickup.text, forKey: "date_pickup")
        defaults.set(textTimePickup.text, forKey: "time_pickup")
        defaults.set(textDateDeliver.text, forKey: "date_deliver")
        defaults.set(textTimeDeliver.text, forKey: "time_deliver")
        // Location
        defaults.set(labelSelectLocation.text, forKey: "address")
        defaults.synchronize()
    }
    
    @IBAction func buttonAddItem(_ sender: Any) {
        if textChooseItem.text == "" {
            let alert = UIAlertController (title: "Per Piece", message: "Please choose one piece.", preferredStyle: .alert)
            alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else if let itemSelected = itemChoose.first(where: { $0.satuan_name == itemSelect }) {
            let alert = UIAlertController (title: "Per Piece", message: "(\(itemSelected.satuan_name)) has been insert.", preferredStyle: .alert)
            alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            itemChoose.append(MyChoose(satuan_name: itemSelect, satuan_price: Int(priceSelect)!, satuan_value: 1))
            tebleLaundryItem.reloadData()
            textChooseItem.text = nil
            print(itemChoose)
            totalPiece += Int(priceSelect)!
            if switchPerKilosAct.isOn {
                if textManyKilos.text == "" {
                    totalKilos = 0
                } else {
                    totalKilos = Int(textManyKilos.text!)! * dinamisPricePerKilos
                }
                totalAll = totalKilos + totalPiece
                labelTotal.text = String(totalAll)
            } else {
                totalAll = 0 + totalPiece
                labelTotal.text = String(totalAll)
            }
            if itemChoose.count > 3 {
                constrainTableItem.constant += 45
                constrainCenter.constant += 45
                constrainAdditem += 45
            }
        }
    }
    
    @objc func dimisKeyboard() {
        view.endEditing(true)
    }
    
    var location: Location? {
        didSet {
            labelSelectLocation.text = location.flatMap({ $0.title }) ?? "No location selected"
            address = String(labelSelectLocation.text!)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(segue.identifier as Any)
        if segue.identifier == "LocationPickerLaundry" {
            let locationPicker = segue.destination as! LocationPickerViewController
            locationPicker.location = location
            locationPicker.showCurrentLocationButton = true
            locationPicker.useCurrentLocationAsHint = true
            locationPicker.selectCurrentLocationInitially = true
            locationPicker.completion = { self.location = $0 }
        } else if segue.identifier == "infoComplete" {
            let DIL = segue.destination as! UltraKlinLaundryDetail
            if switchPerPieceAct.isOn {
                if switchPerKilosAct.isOn {
                    if validPromo == "valid" {
                        DIL.manyKilos = textManyKilos.text!
                        DIL.manyKilosCloth = textManyKilosCloth.text!
                        totalAll = totalPromo + totalPiece
                        DIL.dTotalPiece = totalPiece
                        DIL.dTotalKilos = totalKilos
                        DIL.dTotalAll = totalAll
                        DIL.listChoose = itemChoose
                        DIL.dPromoCode = textPromoCode.text!
                    } else {
                        DIL.manyKilos = textManyKilos.text!
                        DIL.manyKilosCloth = textManyKilosCloth.text!
                        totalAll = totalKilos + totalPiece
                        DIL.dTotalPiece = totalPiece
                        DIL.dTotalKilos = totalKilos
                        DIL.dTotalAll = totalAll
                        DIL.listChoose = itemChoose
                        DIL.dPromoCode = textPromoCode.text!
                    }
                    
                } else {
                    DIL.manyKilos = ""
                    DIL.manyKilosCloth = ""
                    DIL.listChoose = itemChoose
                    totalAll = 0 + totalPiece
                    DIL.dTotalPiece = totalPiece
                    DIL.dTotalKilos = 0
                    DIL.dTotalAll = totalAll
                    DIL.dPromoCode = textPromoCode.text!
                }
            } else if switchPerKilosAct.isOn {
                DIL.manyKilos = textManyKilos.text!
                DIL.manyKilosCloth = textManyKilosCloth.text!
                totalAll = totalKilos + 0
                DIL.dTotalPiece = 0
                DIL.dTotalKilos = totalKilos
                if validPromo == "valid" {
                    DIL.dTotalAll = totalPromo
                } else {
                    DIL.dTotalAll = totalAll
                }
                DIL.dPromoCode = textPromoCode.text!
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadingData()
        
        // Item Laundry Piece
        self.dataRequestListItemPicker()
        // Price Laundry Kilos
        self.dataDinamisRequest()
        
        self.view.isUserInteractionEnabled = true
        self.messageFrame.removeFromSuperview()
        self.activityIndicator.stopAnimating()
        self.refreshControl.endRefreshing()
        
        self.createDatePickerPickup()
        self.viewLayoutLaundryStyle()
        self.location = nil
        self.textPromoCode.delegate = self
        self.constrainCenter.constant = 40
        
        // Load Toolbar
        self.pickerViewServiceLaundry()
        self.pickerViewFragranceLaundry()
        self.pickerViewItemLaundry()
        self.pickerViewTimePickup()
        self.pickerViewTimeDeliver()
        self.toolbarHowManyKilos()
        self.toolbarHowManyKilosCloth()
        
        // Table Delegate
        tebleLaundryItem.delegate = self
        tebleLaundryItem.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        labelServiceWeProvide.addBottomBorderWithColor(color: UIColor.lightGray, width: 1)
        labelYourOrder.addBottomBorderWithColor(color: UIColor.lightGray, width: 1)
        labelAdditional.addBottomBorderWithColor(color: UIColor.lightGray, width: 1)
        labelDelivery.addBottomBorderWithColor(color: UIColor.lightGray, width: 1)
        labelPromoCode.addBottomBorderWithColor(color: UIColor.lightGray, width: 1)
    }
    
    func promoCondition() {
        if textPromoCode.text == "" {
            print("******* non promo")
            let alert = UIAlertController (title: "Promo Code", message: "Please insert code promo.", preferredStyle: .alert)
            alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else if textManyKilos.text == "" {
            let alert = UIAlertController (title: "Per Kilos", message: "Minimum order 3 Kg.", preferredStyle: .alert)
            alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else if Int(textManyKilos.text!)! < 3 {
            let alert = UIAlertController (title: "Per Kilos", message: "Minimum order 3 Kg.", preferredStyle: .alert)
            alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else if textManyKilosCloth.text == "" {
            let alert = UIAlertController (title: "Per Kilos", message: "How many cloth per kilos.", preferredStyle: .alert)
            alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else if Int(textManyKilosCloth.text!)! < 1 {
            let alert = UIAlertController (title: "Per Kilos", message: "Minimum 1 cloth.", preferredStyle: .alert)
            alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            
            self.loadingData()
            
            print("ada promo")
            
            paramPromo = "&name=Laundry Kilos" + "&estimateWeight=" + textManyKilos.text! + "&promo=" + textPromoCode.text!
            
            let url = NSURL(string: Config().URL_Laundry_PromoCode)!
            let session = URLSession.shared
            
            let request = NSMutableURLRequest(url: url as URL)
            
            request.httpMethod = "POST"
            request.httpBody = paramPromo.data(using: String.Encoding.utf8)
            print(paramPromo)
            
            let task = session.dataTask(with: request as URLRequest) {
                data, response, error in
                
                let json = try!JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary
                
                if error != nil {
                   print(error!)
                    return
                }
                
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
                    
                    let subTotal = json["sub Total"] as! Int
                    let totalPay = json["Total Payment"] as! Int
                    
                    DispatchQueue.main.async() {
                        
                        if self.switchPerPieceAct.isOn {
                            if self.switchPerKilosAct.isOn {
                                self.totalPromo = totalPay
                                self.totalAll = self.totalPromo + self.totalPiece
                                self.labelTotal.text = String(self.totalAll)
                                
                                self.validPromo = "valid"
                                self.textPromoCode.isUserInteractionEnabled = false
                                self.textPromoCode.backgroundColor = #colorLiteral(red: 0.007649414241, green: 0.680324614, blue: 0.8433994055, alpha: 1)
                                self.textPromoCode.textColor = UIColor.white
                            } else {
                                self.textPromoCode.text = ""
                                self.totalAll = self.totalPiece
                                self.labelTotal.text = String(self.totalAll)
                                self.textPromoCode.backgroundColor = UIColor.white
                                self.textPromoCode.textColor = UIColor.black
                                self.textPromoCode.isUserInteractionEnabled = true
                                let alert = UIAlertController (title: "Information", message: "Choose service Per Kilos", preferredStyle: .alert)
                                alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        } else {
                            if self.switchPerKilosAct.isOn {
                                self.totalKilos = subTotal
                                self.totalPromo = totalPay
                                self.totalAll = self.totalPromo
                                self.labelTotal.text = String(self.totalAll)
                                
                                self.validPromo = "valid"
                                self.textPromoCode.isUserInteractionEnabled = false
                                self.textPromoCode.backgroundColor = #colorLiteral(red: 0.007649414241, green: 0.680324614, blue: 0.8433994055, alpha: 1)
                                self.textPromoCode.textColor = UIColor.white
                            } else {
                                self.totalAll = 0
                                self.labelTotal.text = String(self.totalAll)
                            }
                        }
                        
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
    
    func toolbarHowManyKilos() {
        // Set toolbar Service
        let toolBarItem = UIToolbar()
        toolBarItem.isTranslucent = true
        toolBarItem.tintColor = UIColor.black
        toolBarItem.sizeToFit()
        
        // Toolbar keyboard Service
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(UltraKlinLaundry.doneClickKilos))
        toolBarItem.setItems([spaceButton, doneButton], animated: false)
        toolBarItem.isUserInteractionEnabled = true
        
        textManyKilos.inputAccessoryView = toolBarItem
    }
    
    @objc func doneClickKilos() {
        if textManyKilos.text == "" {
            totalKilos = 0
            totalAll = totalKilos + totalPiece
            labelTotal.text = String(totalAll)
        } else {
            if switchPerPieceAct.isOn {
                if textManyKilos.text == "" {
                    totalKilos = 0
                } else {
                    totalKilos = Int(textManyKilos.text!)! * dinamisPricePerKilos
                }
                totalAll = totalKilos + totalPiece
                labelTotal.text = String(totalAll)
            } else {
                if textManyKilos.text == "" {
                    totalKilos = 0
                } else {
                    totalKilos = Int(textManyKilos.text!)! * dinamisPricePerKilos
                }
                totalAll = totalKilos + 0
                labelTotal.text = String(totalAll)
            }
        }
        view.endEditing(true)
    }
    
    func toolbarHowManyKilosCloth() {
        // Set toolbar Service
        let toolBarItem = UIToolbar()
        toolBarItem.isTranslucent = true
        toolBarItem.tintColor = UIColor.black
        toolBarItem.sizeToFit()
        
        // Toolbar keyboard Service
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(UltraKlinLaundry.doneClickKilos))
        toolBarItem.setItems([spaceButton, doneButton], animated: false)
        toolBarItem.isUserInteractionEnabled = true
        
        textManyKilosCloth.inputAccessoryView = toolBarItem
    }
    
    func pickerViewTimePickup() {
        // Set Time
        timePicker.datePickerMode = .time
        timePicker.locale = Locale(identifier: "en_GB")
        timePicker.backgroundColor = #colorLiteral(red: 0.007649414241, green: 0.680324614, blue: 0.8433994055, alpha: 1)
        timePicker.minuteInterval = 30
        timePicker.setValue(UIColor.white, forKey: "textColor")
        timePicker.setValue(false, forKey: "highlightsToday")
        
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        let unitFlags:Set<Calendar.Component> = [
            .hour, .day, .month,
            .year,.minute,.hour,.second,
            .calendar]
        dateComponents = Calendar.current.dateComponents(unitFlags, from: timePicker.date)
        if dateComponents.minute! > 30 {
            dateComponents.hour = dateComponents.hour! + 1
            dateComponents.minute = 00
        } else {
            dateComponents.minute = 30
        }
        timePicker.date = dateComponents.date!
        
        // Set toolbar Service
        let toolBarItem = UIToolbar()
        toolBarItem.isTranslucent = true
        toolBarItem.tintColor = UIColor.black
        toolBarItem.sizeToFit()
        
        // Toolbar keyboard Service
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(UltraKlinLaundry.doneTimeClickPickup))
        toolBarItem.setItems([spaceButton, doneButton], animated: false)
        toolBarItem.isUserInteractionEnabled = true
        
        textTimePickup.inputView = timePicker
        textTimePickup.inputAccessoryView = toolBarItem
    }
    
    func pickerViewTimeDeliver() {
        // Set Time
        timePicker.datePickerMode = UIDatePickerMode.time
        timePicker.locale = Locale(identifier: "en_GB")
        timePicker.backgroundColor = #colorLiteral(red: 0.007649414241, green: 0.680324614, blue: 0.8433994055, alpha: 1)
        timePicker.minuteInterval = 30
        timePicker.setValue(UIColor.white, forKey: "textColor")
        timePicker.setValue(false, forKey: "highlightsToday")
        
        // Set toolbar Service
        let toolBarItem = UIToolbar()
        toolBarItem.isTranslucent = true
        toolBarItem.tintColor = UIColor.black
        toolBarItem.sizeToFit()
        
        // Toolbar keyboard Service
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(UltraKlinLaundry.doneTimeClickDeliver))
        toolBarItem.setItems([spaceButton, doneButton], animated: false)
        toolBarItem.isUserInteractionEnabled = true
        
        textTimeDeliver.inputView = timePicker
        textTimeDeliver.inputAccessoryView = toolBarItem
    }
    
    @objc func doneTimeClickDeliver() {
        let timeformatter = DateFormatter()
        timeformatter.timeStyle = .short
        timeformatter.dateFormat = "HH:mm"
        textTimeDeliver.text = timeformatter.string(from: timePicker.date)
        view.endEditing(true)
    }
    
    @objc func doneTimeClickPickup() {
        let timeformatter = DateFormatter()
        timeformatter.timeStyle = .short
        timeformatter.dateFormat = "HH:mm"
        textTimePickup.text = timeformatter.string(from: timePicker.date)
        view.endEditing(true)
    }
    
    func createDatePickerPickup() {
        // Setting datePicker
        datePickerPickup.datePickerMode = UIDatePickerMode.date
        datePickerPickup.locale = NSLocale(localeIdentifier: "en_GB") as Locale
        datePickerPickup.backgroundColor = #colorLiteral(red: 0.007649414241, green: 0.680324614, blue: 0.8433994055, alpha: 1)
        datePickerPickup.setValue(UIColor.white, forKey: "textColor")
        datePickerPickup.setValue(false, forKey: "highlightsToday")
        
        // Set toolbar
        let toolBar = UIToolbar()
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()
        
        // Add the Buttons
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(UltraKlinLaundry.doneClickDatePickup))
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        textDatePickup.inputView = datePickerPickup
        textDatePickup.inputAccessoryView = toolBar
    }
    
    @objc func doneClickDatePickup() {
        // When date pickup
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.dateFormat = "dd-MM-yyyy"
        textDatePickup.text = dateFormatter.string(from: datePickerPickup.date)
        // When date deliver
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        let unitFlags:Set<Calendar.Component> = [
            .hour, .day, .month,
            .year,.minute,.hour,.second,
            .calendar]
        dateComponents = Calendar.current.dateComponents(unitFlags, from: datePickerPickup.date)
// Date Reguler Dinamis (Date Deliver) ==================================================
        dateComponents.day = dateComponents.day! + dinamisDateReguler // <== Date add Dinamis
        datePickerPickup.date = dateComponents.date!
        textDateDeliver.text = dateFormatter.string(from: datePickerPickup.date)
        view.endEditing(true)
    }
    
    func pickerViewServiceLaundry() {
        // Set Service
        selectServicePicker.delegate = self
        selectServicePicker.tintColor = UIColor.white
        selectServicePicker.backgroundColor = #colorLiteral(red: 0.007649414241, green: 0.680324614, blue: 0.8433994055, alpha: 1)
        
        // Set toolbar Service
        let toolBarItem = UIToolbar()
        toolBarItem.isTranslucent = true
        toolBarItem.tintColor = UIColor.black
        toolBarItem.sizeToFit()
        
        // Toolbar keyboard Service
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(UltraKlinLaundry.dimisKeyboard))
        toolBarItem.setItems([spaceButton, doneButton], animated: false)
        toolBarItem.isUserInteractionEnabled = true
        
        textServiceWePro.inputView = selectServicePicker
        textServiceWePro.inputAccessoryView = toolBarItem
    }
    
    func pickerViewFragranceLaundry() {
        // Set Service
        selectFragrancePicker.delegate = self
        selectFragrancePicker.tintColor = UIColor.white
        selectFragrancePicker.backgroundColor = #colorLiteral(red: 0.007649414241, green: 0.680324614, blue: 0.8433994055, alpha: 1)
        
        // Set toolbar Service
        let toolBarItem = UIToolbar()
        toolBarItem.isTranslucent = true
        toolBarItem.tintColor = UIColor.black
        toolBarItem.sizeToFit()
        
        // Toolbar keyboard Service
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(UltraKlinLaundry.doneClickFragrance))
        toolBarItem.setItems([spaceButton, doneButton], animated: false)
        toolBarItem.isUserInteractionEnabled = true
        
        textFragranceWePro.inputView = selectFragrancePicker
        textFragranceWePro.inputAccessoryView = toolBarItem
    }
    
    @objc func doneClickFragrance() {
        if textFragranceWePro.text == "" {
            textFragranceWePro.text = fragrancePick[0]
        }
        view.endEditing(true)
    }
    
    func pickerViewItemLaundry() {
        // Set Item
        selectedPickerItem.delegate = self
        selectedPickerItem.tintColor = UIColor.white
        selectedPickerItem.backgroundColor = #colorLiteral(red: 0.007649414241, green: 0.680324614, blue: 0.8433994055, alpha: 1)
        
        // Set toolbar Per Piece
        let toolBarItem = UIToolbar()
        toolBarItem.isTranslucent = true
        toolBarItem.tintColor = UIColor.black
        toolBarItem.sizeToFit()
        
        // Toolbar keyboard Per Piece
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(UltraKlinLaundry.dimisKeyboard))
        toolBarItem.setItems([spaceButton, doneButton], animated: false)
        toolBarItem.isUserInteractionEnabled = true
        
        textChooseItem.inputView = selectedPickerItem
        textChooseItem.inputAccessoryView = toolBarItem
    }
    
    func dataRequestListItemPicker() {
        loadingData()
// ======================== Dinamis List Item Laundry =========================
        if Reachability.isConnectedToNetwork() {
            print("Internet Connection Available!")
            let url = URL(string: Config().URL_Laundry_List_Item)!
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
                        
                        let jsonPickerItemLaundry = json["data"] as! NSArray
                        
                        DispatchQueue.main.async {
                            
                            for listItemLaundry in jsonPickerItemLaundry {
                                
                                let itemName = (listItemLaundry as AnyObject)["name"] as! String
                                let itemPrice = (listItemLaundry as AnyObject)["price"] as! String
                                
                                self.itemLaundry.append(MyModel(item: itemName, price: Int(itemPrice)!, many: 1))
                            }
                        }
                    }
                }
            }
            task.resume()
        }
        else {
            self.view.isUserInteractionEnabled = true
            self.messageFrame.removeFromSuperview()
            self.activityIndicator.stopAnimating()
            self.refreshControl.endRefreshing()
            print("Internet Connection not Available!")
        }
    }
    
    func dataDinamisRequest() {
// ======================= Date Reguler and Price Per Kilos =======================
        if Reachability.isConnectedToNetwork() {
            print("Internet Connection Available!")
            let url = URL(string: Config().URL_Laundry_AppConfig)!
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
                        
                        let kilosMinimal = json["minimal"] as! Int
                        let kilosPrice = json["perKilo"] as! Int
                        
                        DispatchQueue.main.async {
                            self.servicePick.append(String("Reguler (\(kilosMinimal) Days)"))
                            self.textServiceWePro.text = "Reguler (\(kilosMinimal) Days)"
                            self.dinamisDateReguler = Int(kilosMinimal)
                            self.dinamisPricePerKilos = Int(kilosPrice)
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
    
    internal func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemChoose.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemListLaundry", for: indexPath) as! UltraKlinLaundryTableCell
        cell.labelAddItem.text = itemChoose[indexPath.row].satuan_name + " " + String(itemChoose[indexPath.row].satuan_price)
        cell.labelActItem.text = String(itemChoose[indexPath.row].satuan_value)
        cell.delegate = self
        
        return cell
    }
    
    func swiftyTableViewCellDidTapPlus(_ sender: UltraKlinLaundryTableCell) {
        guard let tappedIndexPath = tebleLaundryItem.indexPath(for: sender) else { return }
        print("PlusItem", sender, tappedIndexPath)
        itemChoose[tappedIndexPath.row].satuan_value += 1
        if switchPerKilosAct.isOn {
            if textManyKilos.text == "" {
                totalKilos = 0
            } else {
                totalKilos = Int(textManyKilos.text!)! * dinamisPricePerKilos
            }
            totalPiece += itemChoose[tappedIndexPath.row].satuan_price
            totalAll = totalKilos + totalPiece
            labelTotal.text = String(totalAll)
        } else {
            totalPiece += itemChoose[tappedIndexPath.row].satuan_price
            totalAll = 0 + totalPiece
            labelTotal.text = String(totalAll)
        }
        tebleLaundryItem.reloadData()
        print(itemChoose)
    }
    
    func swiftyTableViewCellDidTapMin(_ sender: UltraKlinLaundryTableCell) {
        guard let tappedIndexPath = tebleLaundryItem.indexPath(for: sender) else { return }
        print("Min", sender, tappedIndexPath)
        
        if itemChoose[tappedIndexPath.row].satuan_value < 2 {
            // Delete the row
            if switchPerKilosAct.isOn {
                if textManyKilos.text == "" {
                    totalKilos = 0
                } else {
                    totalKilos = Int(textManyKilos.text!)! * dinamisPricePerKilos
                }
                totalPiece -= itemChoose[tappedIndexPath.row].satuan_price
                totalAll = totalKilos + totalPiece
                labelTotal.text = String(totalAll)
            } else {
                totalPiece -= itemChoose[tappedIndexPath.row].satuan_price
                totalAll = 0 + totalPiece
                labelTotal.text = String(totalAll)
            }
            itemChoose.remove(at: tappedIndexPath.row)
            tebleLaundryItem.deleteRows(at: [tappedIndexPath], with: .automatic)
            if itemChoose.count > 2 {
                constrainTableItem.constant -= 45
                constrainCenter.constant -= 45
                constrainAdditem -= 45
            }
        } else {
            if switchPerKilosAct.isOn {
                if textManyKilos.text == "" {
                    totalKilos = 0
                } else {
                    totalKilos = Int(textManyKilos.text!)! * dinamisPricePerKilos
                }
                totalPiece -= itemChoose[tappedIndexPath.row].satuan_price
                totalAll = totalKilos + totalPiece
                labelTotal.text = String(totalAll)
            } else {
                totalPiece -= itemChoose[tappedIndexPath.row].satuan_price
                totalAll = 0 + totalPiece
                labelTotal.text = String(totalAll)
            }
            itemChoose[tappedIndexPath.row].satuan_value -= 1
            tebleLaundryItem.reloadData()
        }
        print(itemChoose)
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
    
    func viewLayoutLaundryStyle() {
        // Style Service We Provide
        viewServiceWeProvide.layer.cornerRadius = 10
        viewServiceWeProvide.layer.borderWidth = 0
        viewServiceWeProvide.layer.borderColor = UIColor.lightGray.cgColor
        viewServiceWeProvide.layer.shadowColor = UIColor.lightGray.cgColor
        viewServiceWeProvide.layer.shadowOffset = CGSize(width: 0, height: 0)
        viewServiceWeProvide.layer.shadowOpacity = 1.0
        viewServiceWeProvide.layer.shadowRadius = 5.0
        viewServiceWeProvide.layer.masksToBounds = false
        // Style Your Order
        viewYourOrder.layer.cornerRadius = 10
        viewYourOrder.layer.borderWidth = 0
        viewYourOrder.layer.borderColor = UIColor.lightGray.cgColor
        viewYourOrder.layer.shadowColor = UIColor.lightGray.cgColor
        viewYourOrder.layer.shadowOffset = CGSize(width: 0, height: 0)
        viewYourOrder.layer.shadowOpacity = 1.0
        viewYourOrder.layer.shadowRadius = 5.0
        viewYourOrder.layer.masksToBounds = false
        // Style Additional Information
        viewAdditional.layer.cornerRadius = 10
        viewAdditional.layer.borderWidth = 0
        viewAdditional.layer.borderColor = UIColor.lightGray.cgColor
        viewAdditional.layer.shadowColor = UIColor.lightGray.cgColor
        viewAdditional.layer.shadowOffset = CGSize(width: 0, height: 0)
        viewAdditional.layer.shadowOpacity = 1.0
        viewAdditional.layer.shadowRadius = 5.0
        viewAdditional.layer.masksToBounds = false
        // Style Delivery to your place
        viewDelivery.layer.cornerRadius = 10
        viewDelivery.layer.borderWidth = 0
        viewDelivery.layer.borderColor = UIColor.lightGray.cgColor
        viewDelivery.layer.shadowColor = UIColor.lightGray.cgColor
        viewDelivery.layer.shadowOffset = CGSize(width: 0, height: 0)
        viewDelivery.layer.shadowOpacity = 1.0
        viewDelivery.layer.shadowRadius = 5.0
        viewDelivery.layer.masksToBounds = false
        // Style Promo Code
        viewPromoCode.layer.cornerRadius = 10
        viewPromoCode.layer.borderWidth = 0
        viewPromoCode.layer.borderColor = UIColor.lightGray.cgColor
        viewPromoCode.layer.shadowColor = UIColor.lightGray.cgColor
        viewPromoCode.layer.shadowOffset = CGSize(width: 0, height: 0)
        viewPromoCode.layer.shadowOpacity = 1.0
        viewPromoCode.layer.shadowRadius = 5.0
        viewPromoCode.layer.masksToBounds = false
        // Style View Button Next
        viewButtonLaundry.layer.borderWidth = 1
        viewButtonLaundry.layer.borderColor = UIColor.lightGray.cgColor
        viewButtonLaundry.layer.shadowColor = UIColor.lightGray.cgColor
        viewButtonLaundry.layer.shadowOffset = CGSize(width: 0, height: -2)
        viewButtonLaundry.layer.shadowOpacity = 1.0
        viewButtonLaundry.layer.shadowRadius = 3
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

extension UltraKlinLaundry: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView == selectedPickerItem {
            return itemLaundry.count
        }
        else if pickerView == selectServicePicker {
            return servicePick.count
        }
        else if pickerView == selectFragrancePicker {
            return fragrancePick.count
        }
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == selectedPickerItem {
            return itemLaundry[row].item + " " + String(itemLaundry[row].price)
        }
        else if pickerView == selectServicePicker {
            return servicePick[row]
        }
        else if pickerView == selectFragrancePicker {
            return fragrancePick[row]
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == selectedPickerItem {
            itemSelect = itemLaundry[row].item
            priceSelect = String(itemLaundry[row].price)
            selectItem = itemLaundry[row].item + " " + String(itemLaundry[row].price)
            textChooseItem.text = selectItem
        }
        else if pickerView == selectServicePicker {
            textServiceWePro.text = servicePick[row]
        }
        else if pickerView == selectFragrancePicker {
            textFragranceWePro.text = fragrancePick[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        var myTitle = NSAttributedString()
        
        if pickerView == selectedPickerItem {
            let titleItem = itemLaundry[row].item + " " + String(itemLaundry[row].price)
            myTitle = NSAttributedString(string: titleItem, attributes: [NSAttributedStringKey.font: UIFont(name: "Arial", size: 12.0)!,NSAttributedStringKey.foregroundColor:UIColor.white])
        }
        else if pickerView == selectServicePicker {
            let titleService =  servicePick[row]
            myTitle = NSAttributedString(string: titleService, attributes: [NSAttributedStringKey.font: UIFont(name: "Arial", size: 12.0)!,NSAttributedStringKey.foregroundColor:UIColor.white])
        }
        else if pickerView == selectFragrancePicker {
            let titleFragrance =  fragrancePick[row]
            myTitle = NSAttributedString(string: titleFragrance, attributes: [NSAttributedStringKey.font: UIFont(name: "Arial", size: 12.0)!,NSAttributedStringKey.foregroundColor:UIColor.white])
        }
        return myTitle
    }
}
