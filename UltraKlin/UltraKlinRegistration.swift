//
//  UltraKlinRegister.swift
//  UltraKlin
//
//  Created by Lini on 27/02/18.
//  Copyright © 2018 PT Lintas Insan Nur Inspira. All rights reserved.
//

import UIKit
import Firebase
import Foundation
import AppsFlyerLib
import FBSDKLoginKit

class UltraKlinRegistration: UIViewController, UITextFieldDelegate {
    
    var rootVC : UIViewController?
    
    var skipRegis = ""
    var hiddenActRegis = false
    
    var param  = String()
    var name   = ""
    var phone  = ""
    var email  = ""
    var pass   = ""
    var repeats = ""
    var paramString = ""
    
    let messageFrame = UIView()
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var textRegisName: UITextField!
    @IBOutlet weak var textRegisPhone: UITextField!
    @IBOutlet weak var textRegisEmail: UITextField!
    @IBOutlet weak var textRegisPass: UITextField!
    @IBOutlet weak var textRegisPassConfirm: UITextField!
    @IBOutlet weak var buttonRegister: UIButton!
    @IBOutlet weak var labelTextLogin: UILabel!
    @IBOutlet weak var buttonLoginAct: UIButton!
    
    @IBOutlet weak var buttonSkipAct: UIButton!
    // Constain Animation
    
    
    @IBOutlet weak var constrainNameCenter: NSLayoutConstraint!
    @IBOutlet weak var constrainPhoneCenter: NSLayoutConstraint!
    @IBOutlet weak var constainEmailCenter: NSLayoutConstraint!
    @IBOutlet weak var constainPassCenter: NSLayoutConstraint!
    @IBOutlet weak var constrainPassConfirmCenter: NSLayoutConstraint!
    
    @IBAction func buttonSkipRegis(_ sender: Any) {
        rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabUltraKlin") as! UltraKlinTabBarView
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = rootVC
    }
    
    @IBAction func buttonRegisClick(_ sender: Any) {
        view.endEditing(true)
        self.name    = textRegisName.text!
        self.phone   = textRegisPhone.text!
        self.email   = textRegisEmail.text!
        self.pass    = textRegisPass.text!
        self.repeats = textRegisPassConfirm.text!
        
        paramString  = "&name=" + name + "&phone=" + phone + "&email=" + email + "&password=" + pass + "&password_confirmation=" + repeats + "&role=customer"
        
        if (name == "" || phone == "" || email == "" || pass == "" || repeats == "" || pass.count < 6 || pass != repeats) {
            if name == "" {
                textRegisName.placeholder = "* Name is required!"
                self.textRegisName.layer.borderColor = UIColor.red.cgColor
            } else {
                textRegisName.placeholder = ""
                self.textRegisName.layer.borderColor = UIColor.lightGray.cgColor
            }
            if phone == "" {
                textRegisPhone.placeholder = "* Phone is required!"
                self.textRegisPhone.layer.borderColor = UIColor.red.cgColor
            } else {
                textRegisPhone.placeholder = ""
                self.textRegisPhone.layer.borderColor = UIColor.lightGray.cgColor
            }
            if email == "" {
                textRegisEmail.placeholder = "* Email is required!"
                self.textRegisEmail.layer.borderColor = UIColor.red.cgColor
            } else {
                textRegisEmail.placeholder = ""
                self.textRegisEmail.layer.borderColor = UIColor.lightGray.cgColor
            }
            if pass.count < 6 {
                textRegisPass.placeholder = "* Password is not 6 character"
                self.textRegisPass.layer.borderColor = UIColor.red.cgColor
                let alert = UIAlertController (title: "Password", message: "Password minimum 6 character.", preferredStyle: .alert)
                alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                textRegisPass.placeholder = ""
                self.textRegisPass.layer.borderColor = UIColor.lightGray.cgColor
            }
            if pass == "" {
                textRegisPass.placeholder = "* Password is required!"
                self.textRegisPass.layer.borderColor = UIColor.red.cgColor
            } else {
                textRegisPass.placeholder = ""
                self.textRegisPass.layer.borderColor = UIColor.lightGray.cgColor
            }
            if repeats == "" {
                textRegisPassConfirm.placeholder = "* Password Confirmation is required!"
                self.textRegisPassConfirm.layer.borderColor = UIColor.red.cgColor
            } else {
                textRegisPassConfirm.placeholder = ""
                self.textRegisPassConfirm.layer.borderColor = UIColor.lightGray.cgColor
            }
            if (pass == repeats) == true {
                self.textRegisPass.layer.borderColor = UIColor.lightGray.cgColor
                self.textRegisPassConfirm.layer.borderColor = UIColor.lightGray.cgColor
            } else {
                self.textRegisPass.layer.borderColor = UIColor.red.cgColor
                self.textRegisPassConfirm.layer.borderColor = UIColor.red.cgColor
            }
        } else {
            self.registerLoadData()
        }
        
    }
    
    func  registerLoadData() {
        self.loadingData()
        print(paramString)
        let url = NSURL(string: Config().URL_Register)!
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = TimeInterval(15)
        config.timeoutIntervalForResource = TimeInterval(15)
        
        let session = URLSession(configuration: config)
        //let session = URLSession.shared
        
        let request = NSMutableURLRequest(url:url  as URL)
        
        request.httpMethod = "POST"
        
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil{
                print("Error: \(String(describing: error?.localizedDescription))")
                let alert = UIAlertController (title: "Connection", message: error?.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction (title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                DispatchQueue.main.async {
                    self.view.isUserInteractionEnabled = true
                    self.messageFrame.removeFromSuperview()
                    self.activityIndicator.stopAnimating()
                    self.refreshControl.endRefreshing()
                }
                return
            }
            
            let json = try!JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String:AnyObject]
            
            if let jerror = json["error"] as? [String:Array<String>] {
                
                let phoneError = jerror["phone"]
                let emailError = jerror["email"]
                
                DispatchQueue.main.async() {
                    
                    self.view.isUserInteractionEnabled = true
                    self.messageFrame.removeFromSuperview()
                    self.activityIndicator.stopAnimating()
                    self.refreshControl.endRefreshing()
                    if phoneError != nil {
                        let alert = UIAlertController(title: "Information", message: "\n \(phoneError![0])", preferredStyle: .alert)
                        alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    } else if emailError != nil {
                        let alert = UIAlertController(title: "Information", message: "\n \(emailError![0])", preferredStyle: .alert)
                        alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        let alert = UIAlertController(title: "Information", message: "\n \(emailError![0]) \n \(phoneError![0])", preferredStyle: .alert)
                        alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                
            } else {
                
                let accToken = json["access_token"] as? String
                let freshToken = json["refresh_token"] as? String
                let typeToken = json["token_type"] as? String
                let expToken = json["expires_in"] as? String
                
                DispatchQueue.main.async() {
                    
                    UserDefaults.standard.set(accToken, forKey: "SavedApiToken")
                    UserDefaults.standard.set(freshToken, forKey: "RefreshApiKey")
                    UserDefaults.standard.set(expToken, forKey: "ExpApiKey")
                    UserDefaults.standard.set(typeToken, forKey: "TypeApiKey")
                    
                    UserDefaults.standard.set(self.textRegisEmail.text!, forKey: "userEmail")
                    UserDefaults.standard.set(self.textRegisPass.text!, forKey: "userPass")
                    
                    AppsFlyerTracker.shared().trackEvent(AFEventParamRegistrationMethod, withValues: [
                        AFEventParamRegistrationMethod : self.textRegisEmail.text!,
                        ]);
                    
                    if self.skipRegis == "Regis" {
                        self.skipRegis = ""
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        self.rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabUltraKlin") as! UltraKlinTabBarView
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.window?.rootViewController = self.rootVC
                    }
                    
                    self.view.isUserInteractionEnabled = true
                    self.messageFrame.removeFromSuperview()
                    self.activityIndicator.stopAnimating()
                    self.refreshControl.endRefreshing()
                }
                
            }
            
        }
        task.resume()
    }
    
    static func updateRootVC() {
        var rootVC : UIViewController?
        
        if UserDefaults.standard.object(forKey: "SavedApiToken") != nil {
            // Check Session Account
            rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabUltraKlin") as! UltraKlinTabBarView
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = rootVC
        } else if UserDefaults.standard.object(forKey: "SessionSosmes") != nil {
            // Check Session Sosmed
            rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabUltraKlin") as! UltraKlinTabBarView
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = rootVC
        }
    }
    
    @objc func dimisKeyboard() {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonSkipAct.isHidden = hiddenActRegis
        labelTextLogin.isHidden = hiddenActRegis
        buttonLoginAct.isHidden = hiddenActRegis
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UltraKlinRegistration.dimisKeyboard))
        view.addGestureRecognizer(tap)
        self.toolbarPhone()
        self.viewLayoutAccountStyle()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.constrainNameCenter.constant += self.view.bounds.width
            self.view.layoutIfNeeded()
            }, completion: nil)
        UIView.animate(withDuration: 0.5, delay: 0.2, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.constrainPhoneCenter.constant += self.view.bounds.width
            self.view.layoutIfNeeded()
            }, completion: nil)
        UIView.animate(withDuration: 0.5, delay: 0.3, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.constainEmailCenter.constant += self.view.bounds.width
            self.view.layoutIfNeeded()
            }, completion: nil)
        UIView.animate(withDuration: 0.5, delay: 0.4, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.constainPassCenter.constant += self.view.bounds.width
            self.view.layoutIfNeeded()
            }, completion: nil)
        UIView.animate(withDuration: 0.5, delay: 0.5, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.constrainPassConfirmCenter.constant += self.view.bounds.width
            self.view.layoutIfNeeded()
            }, completion: nil)
        UIView.animate(withDuration: 0.5, delay: 0.6, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.buttonRegister.alpha = 1
            }, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        constrainNameCenter.constant -= view.bounds.width
        constrainPhoneCenter.constant -= view.bounds.width
        constainEmailCenter.constant -= view.bounds.width
        constainPassCenter.constant -= view.bounds.width
        constrainPassConfirmCenter.constant -= view.bounds.width
        buttonRegister.alpha = 0.0
    }
    
    func animateTextField(TextField: UITextField, up: Bool, withOffset offset:CGFloat) {
        let movementDistance : Int = -Int(offset)
        let movementDuration : Double = 0.3
        let movement : Int = (up ? movementDistance : -movementDistance)
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: CGFloat(movement))
        UIView.commitAnimations()
    }
    
    func textFieldDidBeginEditing(_ TextField: UITextField) {
        self.animateTextField(TextField: TextField, up: true,
                              withOffset: TextField.frame.origin.y / 5)
    }
    
    func textFieldDidEndEditing(_ TextField: UITextField) {
        self.animateTextField(TextField: TextField, up: false,
                              withOffset: TextField.frame.origin.y / 5)
    }
    
    func textFieldShouldReturn(_ TextField: UITextField) -> Bool {
        if TextField == self.textRegisName {
            self.textRegisName.resignFirstResponder()
            self.textRegisPhone.becomeFirstResponder()
        } else if TextField == self.textRegisPhone {
            self.textRegisPhone.resignFirstResponder()
            self.textRegisEmail.becomeFirstResponder()
        } else if TextField == self.textRegisEmail {
            self.textRegisEmail.resignFirstResponder()
            self.textRegisPass.becomeFirstResponder()
        } else if TextField == self.textRegisPass {
            self.textRegisPass.resignFirstResponder()
            self.textRegisPassConfirm.becomeFirstResponder()
        } else if TextField == self.textRegisPassConfirm {
            self.textRegisPassConfirm.resignFirstResponder()
        }
        return true
    }
    
    func toolbarPhone() {
        let toolBar = UIToolbar()
        toolBar.barStyle = .blackTranslucent
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.white
        toolBar.sizeToFit()
        
        // Adds the Buttons
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(UltraKlinRegistration.doneClick))
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textRegisPhone.inputAccessoryView = toolBar
    }
    
    @objc func doneClick() {
        self.textRegisEmail.becomeFirstResponder()
    }
    
    func loadingData() {
        messageFrame.frame = CGRect(x: 90, y: 150 , width: 50, height: 50)
        
        activityIndicator.color = UIColor.white
        messageFrame.layer.cornerRadius = 10
        messageFrame.backgroundColor = UIColor.black
        messageFrame.alpha = 0.8
        activityIndicator.frame = CGRect(x: 90, y: 150, width: 40, height: 40)
        
        messageFrame.addSubview(activityIndicator)
        messageFrame.center = self.view.center
        activityIndicator.center = self.view.center
        view.addSubview(messageFrame)
        view.addSubview(activityIndicator)
        
        self.view.isUserInteractionEnabled = false
        self.activityIndicator.startAnimating()
    }
    
    func viewLayoutAccountStyle() {
        // Style Button Logout
        buttonRegister.layer.cornerRadius = 8
        buttonRegister.layer.borderWidth = 1
        buttonRegister.layer.borderColor = UIColor.lightGray.cgColor
        buttonRegister.layer.shadowColor = UIColor.lightGray.cgColor
        buttonRegister.layer.shadowOffset = CGSize(width: 0, height: 0)
        buttonRegister.layer.shadowOpacity = 1.0
        buttonRegister.layer.shadowRadius = 5.0
        buttonRegister.layer.masksToBounds = false
        // Style TextField Name
        self.textRegisName.layer.borderColor = UIColor.lightGray.cgColor
        self.textRegisName.layer.borderWidth = CGFloat(Float(1.0))
        self.textRegisName.layer.cornerRadius = CGFloat(Float(5.0))
        // Style TextField Password
        self.textRegisPhone.layer.borderColor = UIColor.lightGray.cgColor
        self.textRegisPhone.layer.borderWidth = CGFloat(Float(1.0))
        self.textRegisPhone.layer.cornerRadius = CGFloat(Float(5.0))
        // Style TextField Email
        self.textRegisEmail.layer.borderColor = UIColor.lightGray.cgColor
        self.textRegisEmail.layer.borderWidth = CGFloat(Float(1.0))
        self.textRegisEmail.layer.cornerRadius = CGFloat(Float(5.0))
        // Style TextField Password
        self.textRegisPass.layer.borderColor = UIColor.lightGray.cgColor
        self.textRegisPass.layer.borderWidth = CGFloat(Float(1.0))
        self.textRegisPass.layer.cornerRadius = CGFloat(Float(5.0))
        // Style TextField Password Confirm
        self.textRegisPassConfirm.layer.borderColor = UIColor.lightGray.cgColor
        self.textRegisPassConfirm.layer.borderWidth = CGFloat(Float(1.0))
        self.textRegisPassConfirm.layer.cornerRadius = CGFloat(Float(5.0))
    }
}
