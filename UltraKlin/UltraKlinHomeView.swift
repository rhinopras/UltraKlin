//
//  UltraKlinHome.swift
//  UltraKlin
//
//  Created by Lini on 22/02/18.
//  Copyright © 2018 PT Lintas Insan Nur Inspira. All rights reserved.
//
import UIKit
import ImageIO
import Foundation
import AppRating

class CustomUITextField: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(copy(_:)) || action == #selector(paste(_:)) || action == #selector(cut(_:)) || action == #selector(select(_:)) || action == #selector(selectAll(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
//Bundle.main.releaseVersionNumber
//Bundle.main.buildVersionNumber

class UltraKlinHomeView: UIViewController, UIScrollViewDelegate {
    
    let defaults = UserDefaults.standard
    var appId : String = ""
    
    var datePicker = UIDatePicker()
    
    var loadImage = "Load"
    var imageList : [UIImage] = [#imageLiteral(resourceName: "ImageLoading"),#imageLiteral(resourceName: "ImageLoading"),#imageLiteral(resourceName: "ImageLoading"),#imageLiteral(resourceName: "ImageLoading"),#imageLiteral(resourceName: "ImageLoading")]
    
    var index = 0
    let animationDuration: TimeInterval = 0.25
    let switchingInterval: TimeInterval = 5
    
    @IBOutlet weak var controlSlide: UIPageControl!
    @IBOutlet weak var imageSlide: UIImageView!
    @IBOutlet weak var buttonCleaning: UIButton!
    @IBOutlet weak var buttonLaundry: UIButton!
    @IBOutlet weak var labelCleaning: UILabel!
    
    @IBAction func buttonCleaning(_ sender: UIButton) {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
        } else {
            print("Internet Connection not Available!")
            let alert = UIAlertController (title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
            alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func buttonLaundry(_ sender: UIButton) {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
        } else {
            print("Internet Connection not Available!")
            let alert = UIAlertController (title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
            alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func slideBannerOnline() {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            if loadImage == "Load" {
                for i in 0..<5{
                    if let url = URL(string: "http://ultraklin.com/assets/image/slideIOS\((i+1)).png") {
                        do {
                            let data = try Data(contentsOf: url)
                            self.imageList.append(UIImage(data: data)!)
                        } catch let err {
                            print("error : \(err.localizedDescription)")
                            self.imageList.append(#imageLiteral(resourceName: "slideError"))
                        }
                    }
                }
                loadImage = "Done"
            }
            self.animateImageView()
        } else {
            print("Internet Connection not Available!")
            self.imageList.append(#imageLiteral(resourceName: "slideError"))
            imageSlide.image = imageList[0]
            imageSlide.isUserInteractionEnabled = false
            let alert = UIAlertController (title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
            alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // Load image ========================
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            if error != nil {
                print(error!)
            }
        }.resume()
    }
    
    // Load image ========================
    func downloadImage(url: URL) {
        print("Download Started")
        getDataFromUrl(url: url) { data, response, error in
            guard let data = data, error == nil else {
                self.imageList.removeFirst()
                self.imageList.append(#imageLiteral(resourceName: "slideError"))
                print("Image download error: \(String(describing: error))")
                return
            }
            guard error == nil else {
                print("error: \(String(describing: error))")
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode > 200 {
                    let errorMsg = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                    self.imageList.removeFirst()
                    self.imageList.append(#imageLiteral(resourceName: "slideError"))
                    print("Image download error: \(errorMsg!)")
                    return
                }
            }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                
                self.imageList.removeFirst()
                self.imageList.append(UIImage(data: data)!)
                
                if self.loadImage == "Done" {
                    self.animateImageView()
                }
                self.loadImage = ""
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load image ========================
        if loadImage == "Load" {
            // Load images
            for i in 0..<5{
                print("Begin of code")
                if let url = URL(string: "http://ultraklin.com/assets/image/slideIOS\(i+1).png") {
                    imageSlide.contentMode = .scaleToFill
                    downloadImage(url: url)
                }
                print("End of code. The image will continue downloading in the background and it will be loaded when it ends.")
            }
            loadImage = "Done"
        }
        
        self.buttonDesign()
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(UltraKlinHomeView.swipedRight))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        imageSlide.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(UltraKlinHomeView.swipedRight))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        imageSlide.addGestureRecognizer(swipeLeft)
        
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.lightGray.cgColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 3.0
        self.navigationController?.navigationBar.layer.shadowOpacity = 1
        self.navigationController?.navigationBar.layer.masksToBounds = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func animateImageView() {
        CATransaction.begin()
        CATransaction.setAnimationDuration(animationDuration)
        CATransaction.setCompletionBlock {
            DispatchQueue.main.asyncAfter(deadline: .now() + self.switchingInterval) {
                self.animateImageView()
            }
        }
        let transition = CATransition()
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        imageSlide.layer.add(transition, forKey: kCATransition)
        imageSlide.image = imageList[index]
        controlSlide.currentPage = index
        CATransaction.commit()
        index = index < imageList.count - 1 ? index + 1 : 0
    }
    
    @objc func swipedRight(gesture : UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("User swiped right")
                if imageSlide.image == imageList[0] {
                    let transition = CATransition()
                    transition.type = kCATransitionPush
                    transition.subtype = kCATransitionFromLeft
                    imageSlide.layer.add(transition, forKey: kCATransition)
                    index = 0
                    imageSlide.image = imageList[4]
                    self.controlSlide.currentPage = 4
                } else if imageSlide.image == imageList[1] {
                    let transition = CATransition()
                    transition.type = kCATransitionPush
                    transition.subtype = kCATransitionFromLeft
                    imageSlide.layer.add(transition, forKey: kCATransition)
                    index = 1
                    imageSlide.image = imageList[0]
                    self.controlSlide.currentPage = 0
                } else if imageSlide.image == imageList[2] {
                    let transition = CATransition()
                    transition.type = kCATransitionPush
                    transition.subtype = kCATransitionFromLeft
                    imageSlide.layer.add(transition, forKey: kCATransition)
                    index = 2
                    imageSlide.image = imageList[1]
                    self.controlSlide.currentPage = 1
                } else if imageSlide.image == imageList[3] {
                    let transition = CATransition()
                    transition.type = kCATransitionPush
                    transition.subtype = kCATransitionFromLeft
                    imageSlide.layer.add(transition, forKey: kCATransition)
                    index = 3
                    imageSlide.image = imageList[2]
                    self.controlSlide.currentPage = 2
                } else if imageSlide.image == imageList[4] {
                    let transition = CATransition()
                    transition.type = kCATransitionPush
                    transition.subtype = kCATransitionFromLeft
                    imageSlide.layer.add(transition, forKey: kCATransition)
                    index = 4
                    imageSlide.image = imageList[3]
                    self.controlSlide.currentPage = 3
                }
            case UISwipeGestureRecognizerDirection.left:
                print("User swiped left")
                if imageSlide.image == imageList[0] {
                    let transition = CATransition()
                    transition.type = kCATransitionPush
                    transition.subtype = kCATransitionFromRight
                    imageSlide.layer.add(transition, forKey: kCATransition)
                    index = 2
                    imageSlide.image = imageList[1]
                    self.controlSlide.currentPage = 1
                } else if imageSlide.image == imageList[1] {
                    let transition = CATransition()
                    transition.type = kCATransitionPush
                    transition.subtype = kCATransitionFromRight
                    imageSlide.layer.add(transition, forKey: kCATransition)
                    index = 3
                    imageSlide.image = imageList[2]
                    self.controlSlide.currentPage = 2
                } else if imageSlide.image == imageList[2] {
                    let transition = CATransition()
                    transition.type = kCATransitionPush
                    transition.subtype = kCATransitionFromRight
                    imageSlide.layer.add(transition, forKey: kCATransition)
                    index = 4
                    imageSlide.image = imageList[3]
                    self.controlSlide.currentPage = 3
                } else if imageSlide.image == imageList[3] {
                    let transition = CATransition()
                    transition.type = kCATransitionPush
                    transition.subtype = kCATransitionFromRight
                    imageSlide.layer.add(transition, forKey: kCATransition)
                    index = 0
                    imageSlide.image = imageList[4]
                    self.controlSlide.currentPage = 4
                } else if imageSlide.image == imageList[4] {
                    let transition = CATransition()
                    transition.type = kCATransitionPush
                    transition.subtype = kCATransitionFromRight
                    imageSlide.layer.add(transition, forKey: kCATransition)
                    index = 1
                    imageSlide.image = imageList[0]
                    self.controlSlide.currentPage = 0
                }
            default:
                break
            }
        }
    }
    
    func buttonDesign() {
        // Design Button Cleaning
        buttonCleaning.backgroundColor = UIColor.white
        buttonCleaning.layer.cornerRadius = 5
        buttonCleaning.layer.borderWidth = 0
        buttonCleaning.layer.borderColor = UIColor.lightGray.cgColor
        buttonCleaning.layer.shadowColor = UIColor.lightGray.cgColor
        buttonCleaning.layer.shadowOffset = CGSize(width: 0, height: 0)
        buttonCleaning.layer.shadowOpacity = 1.0
        buttonCleaning.layer.shadowRadius = 5.0
        buttonCleaning.layer.masksToBounds = false
        // Design Button Laundry
        buttonLaundry.backgroundColor = UIColor.white
        buttonLaundry.layer.cornerRadius = 5
        buttonLaundry.layer.borderWidth = 0
        buttonLaundry.layer.borderColor = UIColor.lightGray.cgColor
        buttonLaundry.layer.shadowColor = UIColor.lightGray.cgColor
        buttonLaundry.layer.shadowOffset = CGSize(width: 0, height: 0)
        buttonLaundry.layer.shadowOpacity = 1.0
        buttonLaundry.layer.shadowRadius = 5.0
        buttonLaundry.layer.masksToBounds = false
    }
}
