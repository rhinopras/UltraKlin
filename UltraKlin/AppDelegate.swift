
//
//  AppDelegate.swift
//  UltraKlin
//
//  Created by Lini on 22/02/18.
//  Copyright © 2018 PT Lintas Insan Nur Inspira. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import CoreLocation
import Firebase
import FirebaseMessaging
import UserNotifications
import AppsFlyerLib
import AppRating
import Siren
import FBSDKCoreKit
import GoogleMaps
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, GIDSignInDelegate {
    
    var window: UIWindow?
    
    override init() {
        // first set the appID - this must be the very first call of AppRating!
        AppRating.appID("1303429279");
        
        // enable debug mode (disable this in production mode)
        //AppRating.debugEnabled(true);
        
        // reset the counters (for testing only);
        //AppRating.resetAllCounters();
        
        // set some of the settings (see the github readme for more information about that)
        AppRating.daysUntilPrompt(0);
        AppRating.usesUntilPrompt(9);
        AppRating.secondsBeforePromptIsShown(3);
        AppRating.significantEventsUntilPrompt(0); // set this to zero if you dont't want to use this feature
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Handle push from foreground\(notification.request.content.userInfo)")
        let dict = notification.request.content.userInfo["aps"] as! NSDictionary
        let d : [String : Any] = dict["alert"] as! [String : Any]
        let body : String = d["body"] as! String
        let title : String = d["title"] as! String
        print("Title:\(title)" + "body:\(body)")
        self.showAlertAppDelegate(title: title, message: body, buttonTitle: "ok", window: self.window!)
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Handle push from background or close\(response.notification.request.content.userInfo)")
    }
    
    func showAlertAppDelegate(title: String, message: String, buttonTitle: String, window: UIWindow) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: UIAlertActionStyle.default, handler: nil))
        window.rootViewController?.present(alert, animated: false, completion: nil)
    }
    
    // Push notification received
    func application(_ application: UIApplication, didReceiveRemoteNotification data: [AnyHashable : Any]) {
        // Print notification payload data
        print("Push notification received: \(data)")
    }
    
    // Called when APNs has assigned the device a unique token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Convert token to string
        var token = ""
        for i in 0..<deviceToken.count {
            token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        print("Registration succeeded! Token: ", token)
        AppsFlyerTracker.shared().registerUninstall(deviceToken)
    }
    
    // Called when APNs failed to register the device for push notifications
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // Print the error to console (you should alert the user that registration failed)
        print("APNs registration failed: \(error)")
    }
    
    func application(_ app: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }
    
    func application(_ application: UIApplication,
                     open url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return GIDSignIn.sharedInstance().handle(url as URL?,sourceApplication: sourceApplication, annotation: annotation)
    }

    // Reports app open from deep link for iOS 9 or later
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        // AppFlyer
        AppsFlyerTracker.shared().handleOpen(url, options: options)
        
        // Facebook Sign
        FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        
        // Google Sign
        GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        return true
    }
    
    // Reports app open from a Universal Link for iOS 9 or later
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        AppsFlyerTracker.shared().continue(userActivity, restorationHandler: restorationHandler)
        return true
    }
    
    func setupSiren() {
        let siren = Siren.shared
        
        // Optional
        siren.delegate = self
        
        // Optional
        //siren.debugEnabled = true
        
        // Optional - Change the name of your app. Useful if you have a long app name and want to display a shortened version in the update dialog (e.g., the UIAlertController).
        siren.appName = "UltraKlin"
        
        // Optional - Change the various UIAlertController and UIAlertAction messaging. One or more values can be changes. If only a subset of values are changed, the defaults with which Siren comes with will be used.
        siren.alertMessaging = SirenAlertMessaging(updateTitle: "Update Available",
                                                   updateMessage: "A new version of UltraKlin is available. Please update to version now.",
                                                   updateButtonMessage: "Update Now",
                                                   nextTimeButtonMessage: "Next Time",
                                                   skipVersionButtonMessage: "Skip")
        
        // Optional - Defaults to .Option
        siren.alertType = .force // or .force, .skip, .none
        
        // Optional - Can set differentiated Alerts for Major, Minor, Patch, and Revision Updates (Must be called AFTER siren.alertType, if you are using siren.alertType)
        siren.majorUpdateAlertType = .force
        siren.minorUpdateAlertType = .force
        siren.patchUpdateAlertType = .force
        siren.revisionUpdateAlertType = .force
        
        // Optional - Sets all messages to appear in Russian. Siren supports many other languages, not just English and Russian.
        siren.forceLanguageLocalization = .english
        
        // Optional - Set this variable if your app is not available in the U.S. App Store. List of codes: https://developer.apple.com/library/content/documentation/LanguagesUtilities/Conceptual/iTunesConnect_Guide/Chapters/AppStoreTerritories.html
        //        siren.countryCode = ""
        
        // Optional - Set this variable if you would only like to show an alert if your app has been available on the store for a few days.
        // This default value is set to 1 to avoid this issue: https://github.com/ArtSabintsev/Siren#words-of-caution
        // To show the update immediately after Apple has updated their JSON, set this value to 0. Not recommended due to aforementioned reason in https://github.com/ArtSabintsev/Siren#words-of-caution.
        siren.showAlertAfterCurrentVersionHasBeenReleasedForDays = 0
        
        // Optional (Only do this if you don't call checkVersion in didBecomeActive)
        siren.checkVersion(checkType: .immediately)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if (error == nil) {
            // Perform any operations on signed in user here.
            //let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            //let givenName = user.profile.givenName
            //let familyName = user.profile.familyName
            let email = user.profile.email
            //let userImageURL = user.profile.imageURL(withDimension: 200)
            
            UserDefaults.standard.set(email, forKey: "emailUserGL")
            UserDefaults.standard.set(fullName, forKey: "nameUserGL")
            UserDefaults.standard.set(idToken, forKey: "SessionSosmes")
            
            // [START_EXCLUDE]
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: "ToggleAuthUINotification"),
                object: nil,
                userInfo: ["statusText": "Signed in user:\n\(String(describing: fullName))"])
            
            let mainStoryBoard: UIStoryboard = UIStoryboard(name:"Main", bundle:nil)
            let protectedPage = mainStoryBoard.instantiateViewController(withIdentifier: "tabUltraKlin") as! UltraKlinTabBarView
            let appDelegate = UIApplication.shared.delegate
            appDelegate?.window??.rootViewController = protectedPage
            // [END_EXCLUDE]
        }
        else {
            print("\(error.localizedDescription)")
            // [START_EXCLUDE silent]
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: "ToggleAuthUINotification"), object: nil, userInfo: nil)
            // [END_EXCLUDE]
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // iOS 10 support
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().delegate = self
            let authOption : UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
            options: authOption, completionHandler: {_, _ in })
        }
            
        // iOS 9 support
        else {
            let settings : UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        // Firebase =============================
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        FirebaseApp.configure()
        
        // Google Maps ====================================
        // Provide the Places API with your API key.
        GMSPlacesClient.provideAPIKey("AIzaSyBX76bmvaRhvZ8mHsP4zE3AfyCN9B-NCXI")
        // Provide the Maps API with your API key. We need to provide this as well because the Place
        // Picker displays a Google Map.
        GMSServices.provideAPIKey("AIzaSyDY1soU4JLC_sl1Trdkvpau5mm5Wu0dl6c")
        
        // Cek Session
        UltraKlinRegistration.updateRootVC()
        
        // AppsFlyer ====================================
        AppsFlyerTracker.shared().appsFlyerDevKey = "ayfSQek7FFtQtiT3FqJBjg"
        AppsFlyerTracker.shared().appleAppID = "1303429279"
        
        // For Develop
        //AppsFlyerTracker.shared().isDebug = true
        
        // Checking Version App For Update
        window?.makeKeyAndVisible()
        setupSiren()
        
        // Facebook Sign
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Google Sign
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        // For checking last version for update
        Siren.shared.checkVersion(checkType: .immediately)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        // For checking last version for update
        Siren.shared.checkVersion(checkType: .daily)
        
        // Appflyer
        AppsFlyerTracker.shared().trackAppLaunch()
        AppsFlyerTracker.shared().shouldCollectDeviceName = true
        
        // Login Facebook
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
}

extension AppDelegate: SirenDelegate {
    func sirenDidShowUpdateDialog(alertType: Siren.AlertType) {
        print(#function, alertType)
    }
    
    func sirenUserDidCancel() {
        print(#function)
    }
    
    func sirenUserDidSkipVersion() {
        print(#function)
    }
    
    func sirenUserDidLaunchAppStore() {
        print(#function)
    }
    
    func sirenDidFailVersionCheck(error: Error) {
        print(#function, error)
    }
    
    func sirenLatestVersionInstalled() {
        print(#function, "Latest version of app is installed")
    }
    
    // This delegate method is only hit when alertType is initialized to .none
    func sirenDidDetectNewVersionWithoutAlert(message: String, updateType: UpdateType) {
        print(#function, "\(message).\nRelease type: \(updateType.rawValue.capitalized)")
    }
}
