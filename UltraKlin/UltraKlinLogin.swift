//
//  UltraKlinLogin.swift
//  UltraKlin
//
//  Created by Lini on 27/02/18.
//  Copyright © 2018 PT Lintas Insan Nur Inspira. All rights reserved.
//

import UIKit
import Foundation
import AppsFlyerLib

class UltraKlinLogin: UIViewController, UITextFieldDelegate {
    
    var param = String()
    var email   = ""
    var password  = ""
    var paramString = ""
    
    let messageFrame = UIView()
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var textLoginUsername: UITextField!
    @IBOutlet weak var textLoginPassword: UITextField!
    @IBOutlet weak var buttonLogin: UIButton!
    
    @IBOutlet weak var constainUsernameLogin: NSLayoutConstraint!
    @IBOutlet weak var constainPassLogin: NSLayoutConstraint!
    
    @IBAction func buttonLoginClick(_ sender: Any) {
        view.endEditing(true)
        var rootVC : UIViewController?
        self.buttonLogin.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.buttonLogin.alpha = 1
        }, completion: nil)
        let auth = (UserDefaults.standard.string(forKey: "SavedApiKey"))
        print(auth as Any)
        
        self.email       = textLoginUsername.text!
        self.password    = textLoginPassword.text!
        paramString      = "email=" + email + "&password=" + password
        
        if (email == "" || password == "") {
            if email == ""{
                textLoginUsername.placeholder = "* Email is required!"
            } else {
                textLoginUsername.text = ""
            }
            if password == "" {
                textLoginPassword.placeholder = "* Password is required!"
            } else {
                textLoginPassword.text = ""
            }
            
        } else {
            self.loadingData()
            print(paramString)
            let url = NSURL(string: Config().URL_Login)!
            let session = URLSession.shared
            
            let request = NSMutableURLRequest(url:url as URL)
            
            request.httpMethod = "POST"
            request.httpBody = paramString.data(using: String.Encoding.utf8)
            
            let task = session.dataTask(with: request as URLRequest) {
                data, response, error in
                if error != nil {
                    print("error\(String(describing: error))")
                    return
                }
                print("******* response register = \(String(describing: response))")
                let json = try!JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary
                if (json["success"] as? String) != nil{
                    let keyJson = json["uk_token"] as? String
                    let name    = json["name"] as? String
                    let email    = self.textLoginUsername.text!
                    let defaults = UserDefaults.standard
                    let apiKey = keyJson
                    defaults.set(apiKey, forKey: "SavedApiKey")
                    defaults.set(name, forKey: "name")
                    defaults.synchronize()
                    
                    DispatchQueue.main.async {
                        
                        AppsFlyerTracker.shared().trackEvent(AFEventLogin, withValues: [
                            AFEventLogin : email,
                            ]);
                        
                        rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabUltraKlin") as! UltraKlinTabBarView
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.window?.rootViewController = rootVC
                        
                        self.textLoginPassword.text = ""
                        self.view.isUserInteractionEnabled = true
                        self.messageFrame.removeFromSuperview()
                        self.activityIndicator.stopAnimating()
                        self.refreshControl.endRefreshing()
                    }
                    
                } else {
                    
                    DispatchQueue.main.async {
                        
                        self.view.isUserInteractionEnabled = true
                        self.messageFrame.removeFromSuperview()
                        self.activityIndicator.stopAnimating()
                        self.refreshControl.endRefreshing()
                        
                        let alert = UIAlertController (title: "INFORMATION", message: "\n Login Failed.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                    
                }
                
            }
            task.resume()
        }
        
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
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UltraKlinLogin.dimisKeyboard))
        view.addGestureRecognizer(tap)
        self.viewLayoutAccountStyle()
    }
    
    @objc func dimisKeyboard() {
        view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.constainUsernameLogin.constant += self.view.bounds.width
            self.view.layoutIfNeeded()
        }, completion: nil)
        UIView.animate(withDuration: 0.5, delay: 0.3, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.constainPassLogin.constant += self.view.bounds.width
            self.view.layoutIfNeeded()
        }, completion: nil)
        UIView.animate(withDuration: 0.5, delay: 0.5, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.buttonLogin.alpha = 1
        }, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        constainUsernameLogin.constant -= view.bounds.width
        constainPassLogin.constant -= view.bounds.width
        buttonLogin.alpha = 0.0
    }
    
    func animateTextField(TextField: UITextField, up: Bool, withOffset offset:CGFloat) {
        let movementDistance : Int = -Int(offset)
        let movementDuration : Double = 0.4
        let movement : Int = (up ? movementDistance : -movementDistance)
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: CGFloat(movement))
        UIView.commitAnimations()
    }
    
    func textFieldDidBeginEditing(_ TextField: UITextField) {
        self.animateTextField(TextField: TextField, up: true,
                              withOffset: TextField.frame.origin.y / 3)
    }
    
    func textFieldDidEndEditing(_ TextField: UITextField) {
        self.animateTextField(TextField: TextField, up: false,
                              withOffset: TextField.frame.origin.y / 3)
    }
    
    func textFieldShouldReturn(_ TextField: UITextField) -> Bool {
        if TextField == self.textLoginUsername {
            self.textLoginUsername.resignFirstResponder()
            self.textLoginPassword.becomeFirstResponder()
        } else if TextField == self.textLoginPassword {
            self.textLoginPassword.resignFirstResponder()
        }
        return true
    }
    
    func viewLayoutAccountStyle() {
        // Style Button Logout
        buttonLogin.layer.cornerRadius = 8
        buttonLogin.layer.borderWidth = 1
        buttonLogin.layer.borderColor = UIColor.lightGray.cgColor
        buttonLogin.layer.shadowColor = UIColor.lightGray.cgColor
        buttonLogin.layer.shadowOffset = CGSize(width: 0, height: 0)
        buttonLogin.layer.shadowOpacity = 1.0
        buttonLogin.layer.shadowRadius = 5.0
        buttonLogin.layer.masksToBounds = false
        // Style TextField Username
        self.textLoginUsername.layer.borderColor = UIColor.lightGray.cgColor
        self.textLoginUsername.layer.borderWidth = CGFloat(Float(1.0))
        self.textLoginUsername.layer.cornerRadius = CGFloat(Float(5.0))
        // Style TextField Password
        self.textLoginPassword.layer.borderColor = UIColor.lightGray.cgColor
        self.textLoginPassword.layer.borderWidth = CGFloat(Float(1.0))
        self.textLoginPassword.layer.cornerRadius = CGFloat(Float(5.0))
    }
}
