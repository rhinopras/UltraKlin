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
    
    public let URL_Login:String =  Config.URL_API + "login"
    
    public let URL_Register:String =  Config.URL_API + "auth"
    
    public let URL_Cleaning_Promo:String =  Config.URL_API + "promo/beta"
    
    public let URL_Cleaning_Order:String =  Config.URL_API + "v2/order_beta"
    
    public let URL_Laundry_Order:String =  Config.URL_API + "v2/order_beta"
    
    public let URL_Laundry_List_Item:String =  Config.URL_API + "price/2"
    
    public let URL_Laundry_AppConfig:String =  Config.URL_API + "Dinamic/minKilo"
    
    public let URL_Laundry_PromoCode:String =  Config.URL_API + "promo/beta"
    
    public let URL_History_Order:String =  Config.URL_API + "Order/mobile/"
    
    // API TESTER DEVELOPER
    
    static let URL_API_DEV:String = "http://dev-api.ultraklin.com/api/"
    
    // API NEW
    
    // URL_INDEX.PHP
    static let URL_API_V2_index:String = "http://alpha.ultraklin.com/index.php/"
    // URL_API
    static let URL_API_V2_api:String = "http://alpha.ultraklin.com/api/"
    
    public let URL_Banner_list:String =  Config.URL_API_V2_api + "images/banners/list"
    
    public let URL_Banner_show:String =  Config.URL_API_V2_index + "images/banners/"
}
