//
//  UltraKlinHome.swift
//  UltraKlin
//
//  Created by Lini on 22/02/18.
//  Copyright © 2018 PT Lintas Insan Nur Inspira. All rights reserved.
//
import UIKit
import ImageIO

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
    
    var datePicker = UIDatePicker()
    
    var loadImage = "Load"
    var imageList : [UIImage] = []
    
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
                    let url = URL(string:"http://ultraklin.com/assets/image/slideIOS\((i+1)).png")
                    let data = try? Data(contentsOf: url!)
                    if data != nil {
                        self.imageList.append(UIImage(data: data!)!)
                    } else {
                        print("Internet connection error.")
                        self.imageList.append(#imageLiteral(resourceName: "slideError"))
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.slideBannerOnline()
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
