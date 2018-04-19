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
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import DeviceCheck

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

class UltraKlinHomeView: UIViewController, UIScrollViewDelegate, FSPagerViewDataSource, FSPagerViewDelegate {
    
    var window: UIWindow?
    
    let defaults = UserDefaults.standard
    
    var datePicker = UIDatePicker()
    
    var urlImages : [String] = []
    var nameImages : [String] = []
    var loadImage = "Load"
    var imageList : [UIImage] = []
    var list : Int = 0
    let animationDuration: TimeInterval = 0.25
    var switchingInterval: TimeInterval = 3
    
    // Refresh
    let messageFrame = UIView()
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var buttonCleaning: UIButton!
    @IBOutlet weak var buttonLaundry: UIButton!
    @IBOutlet weak var labelCleaning: UILabel!
    
    @IBAction func itemNavChat(_ sender: Any) {
//        loadingData()
//        let chartPartnerId = "xjtgdM5yfCTEKYt4iPF1WieaJW23"
//        let ref = Database.database().reference().child("users").child(chartPartnerId)
//        ref.observeSingleEvent(of: .value, with: { (snapshot) in
//            guard let dictionary = snapshot.value as? [String: AnyObject] else {
//                return
//            }
//            let user = Person()
//            user.id = chartPartnerId
//            user.name = dictionary["name"] as? String
//            user.email = dictionary["email"] as? String
//            user.profileImageUrl = dictionary["profileImageUrl"] as? String
//            self.showChatControllerForUser(user: user)
//        }, withCancel: nil)
    }
    
    func showChatControllerForUser(user: Person) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        self.navigationController?.pushViewController(chatLogController, animated: true)
        self.view.isUserInteractionEnabled = true
        self.messageFrame.removeFromSuperview()
        self.activityIndicator.stopAnimating()
        self.refreshControl.endRefreshing()
    }
    
    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
            self.pagerView.itemSize = .zero
        }
    }
    
    @IBOutlet weak var pageControl: FSPageControl! {
        didSet {
            self.pageControl.numberOfPages = imageList.count
            self.pageControl.contentHorizontalAlignment = .center
            //self.pageControl.contentInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        }
    }
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return self.urlImages.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        //cell.imageView?.image = UIImage(named: self.urlImages[index])
        cell.imageView?.image = self.imageList[index]
        cell.imageView?.contentMode = .scaleToFill
        //cell.imageView?.clipsToBounds = true
        //cell.textLabel?.text = index.description+index.description
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        pagerView.scrollToItem(at: index, animated: true)
        self.pageControl.currentPage = imageList.count
    }
    
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        guard self.pageControl.currentPage != pagerView.currentIndex else {
            return
        }
        self.pageControl.currentPage = pagerView.currentIndex
    }
    
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
    
//    func slideBannerOnline() {
//        if Reachability.isConnectedToNetwork(){
//            print("Internet Connection Available!")
//            if loadImage == "Load" {
//                for i in 0..<nameImages.count{
//                    if let url = URL(string: Config().URL_Banner_show + urlImages[i]) {
//                        do {
//                            let data = try Data(contentsOf: url)
//                            self.imageList.append(UIImage(data: data)!)
//                        } catch let err {
//                            print("error : \(err.localizedDescription)")
//                            self.imageList.append(#imageLiteral(resourceName: "slideError"))
//                        }
//                    }
//                }
//                loadImage = "Done"
//            }
//            self.animateImageView()
//        } else {
//            print("Internet Connection not Available!")
//            self.imageList.append(#imageLiteral(resourceName: "slideError"))
//            imageSlide.image = imageList[0]
//            imageSlide.isUserInteractionEnabled = false
//            let alert = UIAlertController (title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
//            alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//        }
//    }
    
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
                
//                if self.loadImage == "Done" {
//                    self.animateImageView()
//                }
//                self.loadImage = ""
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if imageList == [] {
            loadBannerFile()
        }
        
        self.buttonDesign()
        
//        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(UltraKlinHomeView.swipedTouch))
//        swipeRight.direction = UISwipeGestureRecognizerDirection.right
//        imageSlide.addGestureRecognizer(swipeRight)
//
//        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(UltraKlinHomeView.swipedTouch))
//        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
//        imageSlide.addGestureRecognizer(swipeLeft)
        
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.lightGray.cgColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 3.0
        self.navigationController?.navigationBar.layer.shadowOpacity = 1
        self.navigationController?.navigationBar.layer.masksToBounds = false
    }
    
    func loadBannerFile() {
        // ======================== Dinamis Banner =========================
        if Reachability.isConnectedToNetwork() {
            
            let url = URL(string: Config().URL_Banner_list)!
            let session = URLSession.shared
            
            let request = NSMutableURLRequest(url: url)
            
            request.httpMethod = "GET"
            
            let task = session.dataTask(with: request as URLRequest) {
                data, response, error in
                
                if error != nil {
                    print("error\(String(describing: error))")
                    return
                }
                do {
                    let json = try?JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! Array<Any>
                    
                    DispatchQueue.main.async {
                        
                        for listImageAdd in json! {
                            
                            let itemName = (listImageAdd as AnyObject)["name"] as! String
                            let itemFile = (listImageAdd as AnyObject)["file"] as! String
                            
                            self.urlImages.append("\(Config().URL_Banner_show)\(Int(self.view.frame.width))/\(itemFile)")
                            self.nameImages.append(itemName)
                            self.imageList.append(#imageLiteral(resourceName: "ImageLoading"))
                        }
                        
                        for i in 0..<self.urlImages.count{
                            self.downloadImage(url: URL(string: self.urlImages[i])!)
                        }
                        
                        self.pagerView.automaticSlidingInterval = 5.0
                        self.pagerView.isInfinite = self.pagerView.isInfinite
                        self.pageControl.numberOfPages = self.urlImages.count
                        
                        //self.controlSlide.numberOfPages = self.urlImages.count
                        //self.animateImageView()
                    }
                }
            }
            task.resume()
        }
        else {
            print("Internet Connection not Available!")
        }
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
        //imageSlide.layer.add(transition, forKey: kCATransition)
        if list != imageList.count {
            print("Begin of code")
            if let url = URL(string: Config().URL_Banner_show + "\(Int(view.frame.width))/" + urlImages[0]) {
                downloadImage(url: url)
            }
            list += 1
            print("The image will continue downloading in the background and it will be loaded when it ends.")
        } else {
            switchingInterval = 0
        }
//        imageSlide.image = imageList[index]
//        controlSlide.currentPage = index
        
        CATransaction.commit()
        //index = index < imageList.count - 1 ? index + 1 : 0
    }
    
//    @objc func swipedTouch(gesture : UIGestureRecognizer) {
//        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
//            switch swipeGesture.direction {
//            case UISwipeGestureRecognizerDirection.right:
//                print("User swiped right")
//                if imageSlide.image == imageList[0] {
//                    let transition = CATransition()
//                    transition.type = kCATransitionPush
//                    transition.subtype = kCATransitionFromLeft
//                    imageSlide.layer.add(transition, forKey: kCATransition)
//                    index = 0
//                    imageSlide.image = imageList[4]
//                    self.controlSlide.currentPage = 4
//                } else if imageSlide.image == imageList[1] {
//                    let transition = CATransition()
//                    transition.type = kCATransitionPush
//                    transition.subtype = kCATransitionFromLeft
//                    imageSlide.layer.add(transition, forKey: kCATransition)
//                    index = 1
//                    imageSlide.image = imageList[0]
//                    self.controlSlide.currentPage = 0
//                } else if imageSlide.image == imageList[2] {
//                    let transition = CATransition()
//                    transition.type = kCATransitionPush
//                    transition.subtype = kCATransitionFromLeft
//                    imageSlide.layer.add(transition, forKey: kCATransition)
//                    index = 2
//                    imageSlide.image = imageList[1]
//                    self.controlSlide.currentPage = 1
//                } else if imageSlide.image == imageList[3] {
//                    let transition = CATransition()
//                    transition.type = kCATransitionPush
//                    transition.subtype = kCATransitionFromLeft
//                    imageSlide.layer.add(transition, forKey: kCATransition)
//                    index = 3
//                    imageSlide.image = imageList[2]
//                    self.controlSlide.currentPage = 2
//                } else if imageSlide.image == imageList[4] {
//                    let transition = CATransition()
//                    transition.type = kCATransitionPush
//                    transition.subtype = kCATransitionFromLeft
//                    imageSlide.layer.add(transition, forKey: kCATransition)
//                    index = 4
//                    imageSlide.image = imageList[3]
//                    self.controlSlide.currentPage = 3
//                }
//            case UISwipeGestureRecognizerDirection.left:
//                print("User swiped left")
//                if imageSlide.image == imageList[0] {
//                    let transition = CATransition()
//                    transition.type = kCATransitionPush
//                    transition.subtype = kCATransitionFromRight
//                    imageSlide.layer.add(transition, forKey: kCATransition)
//                    index = 2
//                    imageSlide.image = imageList[1]
//                    self.controlSlide.currentPage = 1
//                } else if imageSlide.image == imageList[1] {
//                    let transition = CATransition()
//                    transition.type = kCATransitionPush
//                    transition.subtype = kCATransitionFromRight
//                    imageSlide.layer.add(transition, forKey: kCATransition)
//                    index = 3
//                    imageSlide.image = imageList[2]
//                    self.controlSlide.currentPage = 2
//                } else if imageSlide.image == imageList[2] {
//                    let transition = CATransition()
//                    transition.type = kCATransitionPush
//                    transition.subtype = kCATransitionFromRight
//                    imageSlide.layer.add(transition, forKey: kCATransition)
//                    index = 4
//                    imageSlide.image = imageList[3]
//                    self.controlSlide.currentPage = 3
//                } else if imageSlide.image == imageList[3] {
//                    let transition = CATransition()
//                    transition.type = kCATransitionPush
//                    transition.subtype = kCATransitionFromRight
//                    imageSlide.layer.add(transition, forKey: kCATransition)
//                    index = 0
//                    imageSlide.image = imageList[4]
//                    self.controlSlide.currentPage = 4
//                } else if imageSlide.image == imageList[4] {
//                    let transition = CATransition()
//                    transition.type = kCATransitionPush
//                    transition.subtype = kCATransitionFromRight
//                    imageSlide.layer.add(transition, forKey: kCATransition)
//                    index = 1
//                    imageSlide.image = imageList[0]
//                    self.controlSlide.currentPage = 0
//                }
//            default:
//                break
//            }
//        }
//    }
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
