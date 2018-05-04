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
