//
//  ReceiptFetcher.swift
//  UltraKlin
//
//  Created by Lini on 27/03/18.
//  Copyright © 2018 PT Lintas Insan Nur Inspira. All rights reserved.
//

import Foundation
import StoreKit

class ReceiptFetcher : NSObject, SKRequestDelegate {
    
    let receiptRefreshRequest = SKReceiptRefreshRequest()
    
    override init() {
        super.init()
        receiptRefreshRequest.delegate = self
    }
    
    func fetchReceipt() {
        let receiptUrl = Bundle.main.appStoreReceiptURL
        //let receiptUrl = "itms-apps://itunes.apple.com/app/id1303429279"
        
        print(receiptUrl as Any)
        do {
            if let receiptFound = try receiptUrl?.checkResourceIsReachable() {
                if (receiptFound == false) {
                    receiptRefreshRequest.start()
                    if #available(iOS 10.3, *) {
                        SKStoreReviewController.requestReview()
                    } else {
                        // Fallback on earlier versions
                    }
                }
            }
        } catch {
            print("Could not check for receipt presence for some reason... \(error.localizedDescription)")
        }
    }
    
    func requestDidFinish(_ request: SKRequest) {
        print("The request finished successfully")
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Something went wrong: \(error.localizedDescription)")
    }
}
