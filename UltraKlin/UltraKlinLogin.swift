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
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

import FBSDKLoginKit

class UltraKlinLogin: UIViewController, UITextFieldDelegate, GIDSignInUIDelegate {
    
    var messagesController: MessageController?
    
    var rootVC : UIViewController?
    var keyToken = ""
    var skipLogin = ""
    var hiddenActLogin = false
    
    var param = String()
    var email   = ""
    var password  = ""
    var paramString = ""
    var paramReset = ""
    
    // Refresh
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
    
    @IBAction func buttonResetPass(_ sender: Any) {
        view.endEditing(true)
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Forgot Password", message: "Please check your email for recived link from UltraKlin.", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "Email"
            textField.keyboardType = .emailAddress
            textField.returnKeyType = .send
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")
        }
        alert.addAction(cancelAction)
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Send", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            print("Text field: \(String(describing: textField?.text))")
            self.loadingData()
            self.paramReset = "&email=" + (textField?.text)!
            self.resetPassword()
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func buttonHelp(_ sender: Any) {
        let alert = UIAlertController (title: "Help!", message: "1. Click Forgot Password?\n 2. Enter you email, so click Send.\n 3. UltraKlin will be sending email reset password.\n 4. Open Email, so click reset password.\n 5. Enter a new password, so click Reset.\n 6. Congratulation! password have been change. \n \n Note : Check inbox or spam and then click reset password from UltraKlin.", preferredStyle: .alert)
        alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
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
                    UserDefaults.standard.set(currentUser.email, forKey: "emailUserFB")
                    UserDefaults.standard.set(currentUser.displayName, forKey: "nameUserFB")
                    UserDefaults.standard.set(currentUser.phoneNumber, forKey: "phoneUserFB")
                    UserDefaults.standard.set(currentUser.refreshToken, forKey: "SessionSosmes")
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
    
    lazy var profileImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage.init(named: "user")
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.contentMode = .scaleAspectFit
        //imgView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handelSelectProfileImageView)))
        imgView.isUserInteractionEnabled = true
        return imgView
    }()
    
    @IBAction func buttonLoginClick(_ sender: Any) {
        view.endEditing(true)
        
        self.email       = textLoginUsername.text!
        self.password    = textLoginPassword.text!
        paramString      = "email=" + email + "&password=" + password
        
        if (email == "" || password.count < 6 || password == "") {
            if email == ""{
                textLoginUsername.placeholder = "* Email is required!"
            }
            if password == "" {
                textLoginPassword.placeholder = "* Password is required!"
            } else if ((password.count < 6)) {
                let alert = UIAlertController (title: "Password", message: "Password minimum 6 character.", preferredStyle: .alert)
                alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            self.loadingData()
            
            let url = NSURL(string: Config().URL_Login)!
            
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = TimeInterval(15)
            config.timeoutIntervalForResource = TimeInterval(15)
            
            let session = URLSession(configuration: config)
            //let session = URLSession.shared
            
            let request = NSMutableURLRequest(url:url as URL)
            
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            request.httpBody = paramString.data(using: String.Encoding.utf8)
            
            let task = session.dataTask(with: request as URLRequest) {
                data, response, error in
                
                if error != nil {
                    print("error\(String(describing: error?.localizedDescription))")
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
                
                let json = try!JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary
                
                if (json["error"] as? String) != nil {
                    
                    let jsonError = json["message"] as? String
                    
                    DispatchQueue.main.async {
                        
                        self.view.isUserInteractionEnabled = true
                        self.messageFrame.removeFromSuperview()
                        self.activityIndicator.stopAnimating()
                        self.refreshControl.endRefreshing()
                        
                        let alert = UIAlertController (title: "Information", message: jsonError, preferredStyle: .alert)
                        alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                } else {
                    
                    let accToken = json["access_token"] as? String
                    let freshToken = json["refresh_token"] as? String
                    let typeToken = json["token_type"] as? String
                    let expToken = json["expires_in"] as? String
                    
                    DispatchQueue.main.async {
                        // Login Chatting
                        //self.handelLogIn()
                        
                        UserDefaults.standard.set(accToken, forKey: "SavedApiToken")
                        UserDefaults.standard.set(freshToken, forKey: "RefreshApiKey")
                        UserDefaults.standard.set(expToken, forKey: "ExpApiKey")
                        UserDefaults.standard.set(typeToken, forKey: "TypeApiKey")
                        
                        UserDefaults.standard.set(self.textLoginUsername.text, forKey: "userEmail")
                        UserDefaults.standard.set(self.textLoginPassword.text, forKey: "userPass")
                        
                        AppsFlyerTracker.shared().trackEvent(AFEventLogin, withValues: [
                            AFEventLogin : self.textLoginUsername.text!,
                            ]);
                        
                        if self.skipLogin == "Login" {
                            self.skipLogin = ""
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
    }
    
    func resetPassword() {
        
        let url = NSURL(string: Config().URL_Pass_Reset)!
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = TimeInterval(15)
        config.timeoutIntervalForResource = TimeInterval(15)
        
        let session = URLSession(configuration: config)
        //let session = URLSession.shared
        
        let request = NSMutableURLRequest(url:url as URL)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        request.httpBody = paramReset.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil {
                print("error: \(String(describing: error?.localizedDescription))")
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
            
            let json = try!JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary
            
            if let jerror = json["error"] as? NSDictionary {
                let jemail = jerror["email"] as? Array<Any>
                DispatchQueue.main.async {
                    self.view.isUserInteractionEnabled = true
                    self.messageFrame.removeFromSuperview()
                    self.activityIndicator.stopAnimating()
                    self.refreshControl.endRefreshing()
                    
                    let alert = UIAlertController (title: "Information", message: jemail?[0] as? String, preferredStyle: .alert)
                    alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            } else if let jsuccess = json["success"] as? String {
                DispatchQueue.main.async {
                    self.view.isUserInteractionEnabled = true
                    self.messageFrame.removeFromSuperview()
                    self.activityIndicator.stopAnimating()
                    self.refreshControl.endRefreshing()
                    
                    let alert = UIAlertController (title: "Information", message: jsuccess, preferredStyle: .alert)
                    alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                DispatchQueue.main.async {
                    self.view.isUserInteractionEnabled = true
                    self.messageFrame.removeFromSuperview()
                    self.activityIndicator.stopAnimating()
                    self.refreshControl.endRefreshing()
                }
            }
        }
        task.resume()
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
        buttonGoogleAct.layer.cornerRadius = 8
    }
}
