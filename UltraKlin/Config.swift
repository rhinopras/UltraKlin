//
//  Config.swift
//  UltraKlin
//
//  Created by Lini on 19/03/18.
//  Copyright © 2018 PT Lintas Insan Nur Inspira. All rights reserved.
//

import Foundation

public class Config {
    
    static let URL_API:String = "http://alpha.ultraklin.com/index.php/"
    
    public let URL_Login:String =  Config.URL_API + "login" // belum tester
    
    public let URL_Register:String =  Config.URL_API + "auth" // belum tester
    
    public let URL_Cleaning_Promo:String =  Config.URL_API + "promo/beta" // masih ada error
    
    public let URL_Cleaning_Order:String =  Config.URL_API + "v2/order_beta" // lancar
    
    public let URL_Laundry_Order:String =  Config.URL_API + "v2/order_beta" // lancar
    
    public let URL_Laundry_List_Item:String =  Config.URL_API + "price/2" // lancar
    
    public let URL_Laundry_AppConfig:String =  Config.URL_API + "Dinamic/minKilo" // lancar
    
    public let URL_Laundry_PromoCode:String =  Config.URL_API + "promo/beta" // masih ada error
    
    public let URL_History_Order:String =  Config.URL_API + "Order/mobile/"
    
}
