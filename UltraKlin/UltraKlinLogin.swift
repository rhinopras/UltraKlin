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
import Firebase
import FBSDKLoginKit

class UltraKlinLogin: UIViewController, UITextFieldDelegate, GIDSignInUIDelegate {
    
    let defaults = UserDefaults.standard
    var rootVC : UIViewController?
    var keyToken = ""
    var skipLogin = ""
    var hiddenActLogin = false
    
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
    @IBOutlet weak var buttonSkipFunc: UIButton!
    @IBOutlet weak var buttonLoginFBAct: UIButton!
    @IBOutlet weak var labelTextRegis: UILabel!
    @IBOutlet weak var buttonRegisAct: UIButton!
    @IBOutlet weak var buttonGoogleAct: UIButton!
    
    @IBOutlet weak var constainUsernameLogin: NSLayoutConstraint!
    @IBOutlet weak var constainPassLogin: NSLayoutConstraint!
    
    @IBAction func buttonGoogleSignIn(_ sender: Any) {
        loadingData()
        GIDSignIn.sharedInstance().signIn()
        self.view.isUserInteractionEnabled = true
        self.messageFrame.removeFromSuperview()
        self.activityIndicator.stopAnimating()
        self.refreshControl.endRefreshing()
    }
    
    @IBAction func buttonSkipLogin(_ sender: Any) {
        self.rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabUltraKlin") as! UltraKlinTabBarView
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = self.rootVC
    }
    
    @IBAction func buttonFacebook(_ sender: Any) {
        loadingData()
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                self.view.isUserInteractionEnabled = true
                self.messageFrame.removeFromSuperview()
                self.activityIndicator.stopAnimating()
                self.refreshControl.endRefreshing()
                return
            }
            
            guard let accessToken = FBSDKAccessToken.current() else {
                print("Failed to get access token")
                self.view.isUserInteractionEnabled = true
                self.messageFrame.removeFromSuperview()
                self.activityIndicator.stopAnimating()
                self.refreshControl.endRefreshing()
                return
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            // Perform login by calling Firebase APIs
            Auth.auth().signIn(with: credential, completion: { (user, error) in
                print(user as Any)
                if let error = error {
                    print("Login error: \(error.localizedDescription)")
                    let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                    self.view.isUserInteractionEnabled = true
                    self.messageFrame.removeFromSuperview()
                    self.activityIndicator.stopAnimating()
                    self.refreshControl.endRefreshing()
                    return
                }
                
                if let currentUser = Auth.auth().currentUser {
                    self.defaults.set(currentUser.email, forKey: "emailUser")
                    self.defaults.set(currentUser.displayName, forKey: "nameUser")
                    self.defaults.set(currentUser.phoneNumber, forKey: "phoneUser")
                    self.defaults.set(currentUser.email, forKey: "SessionSosmes")
                    print(currentUser.email! + " " + currentUser.displayName!)
                }
                
                if self.skipLogin == "Login" {
                    self.skipLogin = ""
                    self.navigationController?.popViewController(animated: true)
                    
                } else {
                    
                    // Present the main view
                    self.rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabUltraKlin") as! UltraKlinTabBarView
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController = self.rootVC
                }
                
                self.view.isUserInteractionEnabled = true
                self.messageFrame.removeFromSuperview()
                self.activityIndicator.stopAnimating()
                self.refreshControl.endRefreshing()
            })
            
        }
        
    }
    
    @IBAction func buttonLoginClick(_ sender: Any) {
        view.endEditing(true)
        
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
                
                if (json["success"] as? String) != nil {
                    
                    let keyJson = json["uk_token"] as? String
                    let name    = json["name"] as? String
                    
                    DispatchQueue.main.async {
                        
                        let email    = self.textLoginUsername.text!
                        let apiKey = keyJson
                        self.keyToken = keyJson!
                        self.defaults.set(apiKey, forKey: "SavedApiKey")
                        self.defaults.set(name, forKey: "name")
                        self.defaults.synchronize()
                        
                        AppsFlyerTracker.shared().trackEvent(AFEventLogin, withValues: [
                            AFEventLogin : email,
                            ]);
                        
                        if self.skipLogin == "Login" {
                            self.skipLogin = ""
                            self.navigationController?.popViewController(animated: true)
                            
                        } else {
                            
                            self.rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabUltraKlin") as! UltraKlinTabBarView
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            appDelegate.window?.rootViewController = self.rootVC
                        }
                        
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
                        
                        let alert = UIAlertController (title: "Information", message: "Login Failed.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                    
                }
                
            }
            task.resume()
        }
        
    }
    
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        refreshControl.endRefreshing()
        activityIndicator.removeFromSuperview()
        
    }
    
    // Present a view that prompts the user to sign in with Google
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        present(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        viewController.dismiss(animated: true, completion: nil)
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
        print(skipLogin)
        
        // Google Sign In
        GIDSignIn.sharedInstance().uiDelegate = self
        
        buttonSkipFunc.isHidden = hiddenActLogin
        labelTextRegis.isHidden = hiddenActLogin
        buttonRegisAct.isHidden = hiddenActLogin
        
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
                              withOffset: TextField.frame.origin.y / 15)
    }
    
    func textFieldDidEndEditing(_ TextField: UITextField) {
        self.animateTextField(TextField: TextField, up: false,
                              withOffset: TextField.frame.origin.y / 15)
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
        // Button Login Sosmed
        buttonLoginFBAct.layer.cornerRadius = 8
    }
}
