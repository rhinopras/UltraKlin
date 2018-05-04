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

struct profile {
    let name : String?
    let phone : String?
    let email : String?
    let logout : String?
}

class UltraKlinTableCellProfile : UITableViewCell {
    @IBOutlet weak var labelProfileLoad: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

class UltraKlinAccountView: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableProfileView: UITableView!
    
    // Refresh
    let messageFrame = UIView()
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    var refreshControl = UIRefreshControl()
    
    fileprivate let sectionTitles = ["Name", "Phone number", "Email", ""]
    
    var dataProfile : [profile] = []
    
    func logoutAct() {
        
        let alert = UIAlertController(title: "Confirmation", message: "Logout from this app ?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) {
            (action) -> Void in
            
            // Sign Out Chat
            do {
                try Auth.auth().signOut()
            } catch let logoutError {
                print("Chatting sign out : \(logoutError)")
            }
            
            // Google Sign Out
            GIDSignIn.sharedInstance().signOut()
            
            // Facebook Sign Out
            FBSDKAccessToken.current()
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            FBSDKAccessToken.setCurrent(nil)
            UserDefaults.standard.removeObject(forKey: "emailUser")
            UserDefaults.standard.removeObject(forKey: "nameUser")
            UserDefaults.standard.removeObject(forKey: "SessionSosmes")
            
            // Account Sigout
            UserDefaults.standard.removeObject(forKey: "SavedApiToken")
            UserDefaults.standard.removeObject(forKey: "name")
            
            var rootVC : UIViewController?
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
        tableProfileView.delegate = self
        tableProfileView.dataSource = self
        
        self.viewLayoutAccountStyle()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkingSession()
    }
    
    func checkingSession() {
        if UserDefaults.standard.object(forKey: "SavedApiToken") == nil {
            // User not yet login ======================
            let alert = UIAlertController(title: "Login", message: "You must login first.", preferredStyle: .alert)
            
            let loginAction = UIAlertAction(title: "Login", style: .default) {
                (action) -> Void in
                // Login
                let myVC = self.storyboard?.instantiateViewController(withIdentifier: "ultraKlinLogin") as! UltraKlinLogin
                myVC.skipLogin = "Login"
                myVC.hiddenActLogin = true
                self.navigationController?.pushViewController(myVC, animated: true)
            }
            let regisAction = UIAlertAction(title: "Register", style: .default) {
                (action) -> Void in
                // Login
                let myVC = self.storyboard?.instantiateViewController(withIdentifier: "ultraKlinRegistration") as! UltraKlinRegistration
                myVC.skipRegis = "Regis"
                myVC.hiddenActRegis = true
                self.navigationController?.pushViewController(myVC, animated: true)
            }
            let cancelAction = UIAlertAction(title: "Not now", style: .cancel) {
                UIAlertAction in
            }
            alert.addAction(loginAction)
            alert.addAction(regisAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            loadingData()
            loadProfile()
        }
    }
    
    func loadProfile() {
        if Reachability.isConnectedToNetwork() {
            print("Internet Connection Available!")
            let auth = UserDefaults.standard.string(forKey: "SavedApiToken")
            
            let url = NSURL(string: Config().URL_Profile)!
            
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = TimeInterval(15)
            config.timeoutIntervalForResource = TimeInterval(15)
            
            let session = URLSession(configuration: config)
            //let session = URLSession.shared
            
            let request = NSMutableURLRequest(url: url as URL)
            
            request.httpMethod = "GET"
            request.setValue("Bearer \(auth!)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            let task = session.dataTask(with: request as URLRequest) {
                data, response, error in
                
                if error != nil {
                    print("error :\(String(describing: error?.localizedDescription))")
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
                
                if let dataJsonE = json["error"] as? String {
                    let alert = UIAlertController (title: "Information", message: dataJsonE, preferredStyle: .alert)
                    alert.addAction(UIAlertAction (title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    DispatchQueue.main.async {
                        self.view.isUserInteractionEnabled = true
                        self.messageFrame.removeFromSuperview()
                        self.activityIndicator.stopAnimating()
                        self.refreshControl.endRefreshing()
                    }
                    
                } else {
                    
                    let name = json["name"] as? String
                    let phone = json["phone"] as? String
                    let email = json["email"] as? String
                    
                    DispatchQueue.main.async {
                        
                        self.dataProfile.removeAll()
                        self.dataProfile.append(profile(name: name, phone: phone, email: email, logout: "Logout"))
                        
                        self.tableProfileView.reloadData()
                        
                        self.view.isUserInteractionEnabled = true
                        self.messageFrame.removeFromSuperview()
                        self.activityIndicator.stopAnimating()
                        self.refreshControl.endRefreshing()
                    }
                }
            }
            task.resume()
        } else {
            print("Internet Connection not Available!")
            let alert = UIAlertController (title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
            alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            self.view.isUserInteractionEnabled = true
            self.messageFrame.removeFromSuperview()
            self.activityIndicator.stopAnimating()
            self.refreshControl.endRefreshing()
        }
    }
    
    // MARK:- UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.dataProfile.count
        case 1:
            return self.dataProfile.count
        case 2:
            return self.dataProfile.count
        case 3:
            return self.dataProfile.count
        default:
            break
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            // Name
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellProfile", for: indexPath) as! UltraKlinTableCellProfile
            cell.labelProfileLoad.text = dataProfile[indexPath.row].name
            return cell
        case 1:
            // Phone
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellProfile", for: indexPath) as! UltraKlinTableCellProfile
            cell.labelProfileLoad.text = dataProfile[indexPath.row].phone
            return cell
        case 2:
            // Email
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellProfile", for: indexPath) as! UltraKlinTableCellProfile
            cell.labelProfileLoad.text = dataProfile[indexPath.row].email
            return cell
        case 3:
            // Logout
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellProfile", for: indexPath) as! UltraKlinTableCellProfile
            cell.labelProfileLoad.text = dataProfile[indexPath.row].logout
            cell.labelProfileLoad.textAlignment = .center
            cell.labelProfileLoad.textColor = UIColor.white
            cell.backgroundColor = #colorLiteral(red: 0.007649414241, green: 0.680324614, blue: 0.8433994055, alpha: 1)
            return cell
        default:
            break
        }
        return tableView.dequeueReusableCell(withIdentifier: "cellProfile")!
    }
    
    // MARK:- UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 3:
            logoutAct()
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionTitles[section]
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 35 : 20
    }
    
    func loadingData() {
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
    
    func viewLayoutAccountStyle() {
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.lightGray.cgColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 2.0
        self.navigationController?.navigationBar.layer.shadowOpacity = 1
        self.navigationController?.navigationBar.layer.masksToBounds = false
    }
}
