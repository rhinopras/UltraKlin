//
//  UltraKlinAccountView.swift
//  UltraKlin
//
//  Created by Lini on 22/02/18.
//  Copyright © 2018 PT Lintas Insan Nur Inspira. All rights reserved.
//
import UIKit
import Foundation
import Firebase
import FBSDKLoginKit
import GoogleSignIn

class UltraKlinAccountView: UIViewController {
    
    @IBOutlet weak var buttonLogoutStyle: UIButton!
    
    @IBAction func buttonLogout(_ sender: Any) {
        
        var rootVC : UIViewController?
        
        let alert = UIAlertController(title: "Confirmation", message: "Logout from this app ?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) {
            (action) -> Void in
            
            let defaults = UserDefaults.standard
            
            // Google Sign Out
            GIDSignIn.sharedInstance().signOut()
            
            // Facebook Sign Out
            FBSDKAccessToken.current()
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            FBSDKAccessToken.setCurrent(nil)
            defaults.removeObject(forKey: "emailUser")
            defaults.removeObject(forKey: "nameUser")
            defaults.removeObject(forKey: "SessionSosmes")
            
            // Account Sigout
            defaults.removeObject(forKey: "SavedApiKey")
            defaults.removeObject(forKey: "name")
            rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ultraKlinLogin") as! UltraKlinLogin
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = rootVC
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")
        }
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewLayoutAccountStyle()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func viewLayoutAccountStyle() {
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.lightGray.cgColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 2.0
        self.navigationController?.navigationBar.layer.shadowOpacity = 1
        self.navigationController?.navigationBar.layer.masksToBounds = false
        // Style Button Logout
        buttonLogoutStyle.layer.cornerRadius = 8
        buttonLogoutStyle.layer.borderWidth = 0
        buttonLogoutStyle.layer.borderColor = UIColor.lightGray.cgColor
        buttonLogoutStyle.layer.shadowColor = UIColor.lightGray.cgColor
        buttonLogoutStyle.layer.shadowOffset = CGSize(width: 0, height: 0)
        buttonLogoutStyle.layer.shadowOpacity = 1.0
        buttonLogoutStyle.layer.shadowRadius = 5.0
        buttonLogoutStyle.layer.masksToBounds = false
    }
}
