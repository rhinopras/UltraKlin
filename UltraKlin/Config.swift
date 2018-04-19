//
//  Config.swift
//  UltraKlin
//
//  Created by Lini on 19/03/18.
//  Copyright © 2018 PT Lintas Insan Nur Inspira. All rights reserved.
//

import Foundation

public class Config {
    
    static let URL_API:String = "http://api.ultraklin.com/index.php/"
    
    // API TESTER DEVELOPER
    static let URL_API_DEV:String = "http://dev-api.ultraklin.com/api/"
    
    // API NEW
    
    // URL_INDEX.PHP
    static let URL_API_V2_index:String = "http://alpha.ultraklin.com/index.php/"
    // URL_API
    static let URL_API_V2_api:String = "http://alpha.ultraklin.com/api/"
    
    
//====================================================================================
    
    public let URL_Login:String =  Config.URL_API_V2_api + "login"
    
    public let URL_Register:String =  Config.URL_API_V2_api + "register"
    
    public let URL_Promo:String =  Config.URL_API_V2_api + "promotions/check"
    
    public let URL_Order:String =  Config.URL_API_V2_api + "orders"
    
    public let URL_Profile:String =  Config.URL_API_V2_api + "user/profile"
    
    public let URL_Package_Cleaning:String =  Config.URL_API_V2_api + "packages/cleaning-regular/items/list"
    
    public let URL_Laundry_Piece:String =  Config.URL_API_V2_api + "packages/laundry-pieces-regular/items/list"
    
    public let URL_Laundry_Kilos:String =  Config.URL_API_V2_api + "packages/laundry-kilos-regular/items/list"
    
    public let URL_Banner_list:String =  Config.URL_API_V2_api + "images/banners/list"
    
    public let URL_Banner_show:String =  Config.URL_API_V2_api + "images/banners/"
    
    public let URL_History:String =  Config.URL_API_V2_api + "orders"
}
