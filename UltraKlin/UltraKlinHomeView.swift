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

struct serviceMenu {
    let serviceName: String?
    let serviceimage: UIImage?
}

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
    
    var datePicker = UIDatePicker()
    
    var urlImages : [String] = []
    var nameImages : [String] = []
    var loadImage = "Load"
    var imageList : [UIImage] = []
    var list : Int = 0
    
    var serviceArray: [serviceMenu] = []
    fileprivate let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    fileprivate let itemsPerRow: CGFloat = 4
    var paddingSpace : Int = 0
    var availableWidth : Int = 0
    var widthPerItem : Int = 0
    var heightcell : Int = 0
    
    // Refresh
    let messageFrame = UIView()
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var buttonCleaning: UIButton!
    @IBOutlet weak var buttonLaundry: UIButton!
    @IBOutlet weak var buttonPest: UIButton!
    @IBOutlet weak var labelCleaning: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var constraintCollectionView: NSLayoutConstraint!
    @IBOutlet weak var constraints: NSLayoutConstraint!
    
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
            self.pageControl.numberOfPages = urlImages.count
            self.pageControl.contentHorizontalAlignment = .center
            //self.pageControl.contentInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        }
    }
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return self.urlImages.count
    }
    
    func getDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        //cell.imageView?.image = UIImage(contentsOfFile: self.urlImages[index])
        //cell.imageView?.image = self.imageList[index]
        let fileManager = FileManager.default
        let imagePAth = (self.getDirectoryPath() as NSString).appendingPathComponent(self.urlImages[index])
        if fileManager.fileExists(atPath: imagePAth){
            cell.imageView?.image = UIImage(contentsOfFile: imagePAth)
        } else {
            print("No Image")
        }
        cell.imageView?.contentMode = .scaleToFill
        //cell.imageView?.clipsToBounds = true
        //cell.textLabel?.text = index.description+index.description
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        pagerView.scrollToItem(at: index, animated: true)
        self.pageControl.currentPage = urlImages.count
    }
    
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        guard self.pageControl.currentPage != pagerView.currentIndex else {
            return
        }
        self.pageControl.currentPage = pagerView.currentIndex
    }
    
    @IBAction func buttonPestAct(_ sender: Any) {
        let alert = UIAlertController (title: "Comming soon", message: "Hiring a professional pest control service can have several benefits when comparing it to controlling pests such as rodents, spiders or termites on your own.", preferredStyle: .alert)
        alert.addAction(UIAlertAction (title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
    
    // Load image ========================
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            if error != nil {
                print("\(String(describing: error?.localizedDescription))")
            }
        }.resume()
    }
    
    // Load image ========================
    func downloadImage(url: URL) {
        print("Download Started")
        getDataFromUrl(url: url) { data, response, error in
            
            guard let data = data, error == nil else {
                print("Image download error: \(String(describing: error?.localizedDescription))")
                FirebaseCrashMessage("Image download error: \(String(describing: error?.localizedDescription))")
                return
            }
            
            guard error == nil else {
                print("error: \(String(describing: error?.localizedDescription))")
                FirebaseCrashMessage("Load banner error : \(String(describing: error?.localizedDescription))")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode > 200 {
                    let errorMsg = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                    print("Image download error: \(errorMsg!)")
                    FirebaseCrashMessage("Image download error: \(errorMsg!)")
                    return
                }
            }
            
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            
            DispatchQueue.main.async() {
                self.saveImageDocumentDirectory(data: UIImage(data: data)!, name: response?.suggestedFilename ?? url.lastPathComponent)
            }
        }
    }
    
    func saveImageDocumentDirectory(data: UIImage, name: String){
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(name)
        let image = data
        let imageData = UIImagePNGRepresentation(image)
        fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        serviceViewDinamis()
        
        if urlImages == [] {
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
            
            let url = URL(string: Config().URL_Banner_List)!
            
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = TimeInterval(15)
            config.timeoutIntervalForResource = TimeInterval(15)
            
            let session = URLSession(configuration: config)
            //let session = URLSession.shared
            
            let request = NSMutableURLRequest(url: url)
            
            request.httpMethod = "GET"
            
            let task = session.dataTask(with: request as URLRequest) {
                data, response, error in
                
                if error != nil {
                    print("\(String(describing: error?.localizedDescription))")
                    DispatchQueue.main.async {
                        self.view.isUserInteractionEnabled = true
                        self.messageFrame.removeFromSuperview()
                        self.activityIndicator.stopAnimating()
                        self.refreshControl.endRefreshing()
                    }
                    return
                }
                do {
                    let json = try?JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! Array<Any>
                    
                    DispatchQueue.main.async {
                        
                        for listImageAdd in json! {
                            let itemName = (listImageAdd as AnyObject)["name"] as! String
                            let itemFile = (listImageAdd as AnyObject)["file"] as! String
                            self.urlImages.append(itemFile)
                            self.nameImages.append(itemName)
                        }
                        for i in 0..<self.urlImages.count{
                            self.downloadImage(url: URL(string: "\(Config().URL_Banner_Show)\(Int(self.view.frame.width)+400)/\(self.urlImages[i])")!)
                        }
                        self.pagerView.automaticSlidingInterval = 4.0
                        self.pagerView.isInfinite = self.pagerView.isInfinite
                        self.pageControl.numberOfPages = self.urlImages.count
                    }
                }
            }
            task.resume()
        }
        else {
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        constraints.constant = 0
    }
    
//    func animateImageView() {
//        CATransaction.begin()
//        CATransaction.setAnimationDuration(animationDuration)
//        CATransaction.setCompletionBlock {
//            DispatchQueue.main.asyncAfter(deadline: .now() + self.switchingInterval) {
//                self.animateImageView()
//            }
//        }
//        let transition = CATransition()
//        transition.type = kCATransitionPush
//        transition.subtype = kCATransitionFromRight
//        imageSlide.layer.add(transition, forKey: kCATransition)
//        if list != imageList.count {
//            print("Begin of code")
//            if let url = URL(string: Config().URL_Banner_Show + "\(Int(view.frame.width))/" + urlImages[0]) {
//                downloadImage(url: url)
//            }
//            list += 1
//        } else {
//            switchingInterval = 0
//        }
//        imageSlide.image = imageList[index]
//        controlSlide.currentPage = index
//
//        CATransaction.commit()
//        index = index < imageList.count - 1 ? index + 1 : 0
//    }
    
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
    
    func serviceViewDinamis() {
        loadingData()
        // ======================= List Item Cleaning =======================
        if Reachability.isConnectedToNetwork() {
            print("Internet Connection Available!")
            let url = URL(string: Config().URL_Service_List)!
            
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = TimeInterval(15)
            config.timeoutIntervalForResource = TimeInterval(15)
            
            let session = URLSession(configuration: config)
            //let session = URLSession.shared
            
            let request = NSMutableURLRequest(url: url)
            
            request.httpMethod = "GET"
            
            let task = session.dataTask(with: request as URLRequest) {
                data, response, error in
                
                if error != nil {
                    print("error : \(String(describing: error))")
                    let alert = UIAlertController (title: "Connection", message: error?.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction (title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    DispatchQueue.main.async {
                        self.view.isUserInteractionEnabled = true
                        self.messageFrame.removeFromSuperview()
                        self.activityIndicator.stopAnimating()
                        self.refreshControl.endRefreshing()
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                    return
                }
                do {
                    if let json = try!JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? Array<Any> {
                        
                        DispatchQueue.main.async {
                            
                            for addData in json {
                                
                                let name = (addData as AnyObject)["name"] as! String
                                let displayName = (addData as AnyObject)["display_name"] as! String
                                
                                if name == "cleaning" {
                                    self.serviceArray.append(serviceMenu(serviceName: displayName, serviceimage: #imageLiteral(resourceName: "historyC")))
                                } else {
                                    self.serviceArray.append(serviceMenu(serviceName: displayName, serviceimage: #imageLiteral(resourceName: "historyL")))
                                }
                            }
                            
                            self.collectionView.reloadData()
                            
                            self.paddingSpace = Int(self.sectionInsets.left * (self.itemsPerRow + 1))
                            self.availableWidth = Int(self.view.frame.width) - self.paddingSpace
                            self.widthPerItem = Int(self.availableWidth) / Int(self.itemsPerRow)
                            
                            self.constraintCollectionView.constant = CGFloat((self.widthPerItem + 50 + Int(self.sectionInsets.top + self.sectionInsets.bottom)))
                            
                            self.view.isUserInteractionEnabled = true
                            self.messageFrame.removeFromSuperview()
                            self.activityIndicator.stopAnimating()
                            self.refreshControl.endRefreshing()
                        }
                    }
                }
            }
            task.resume()
        } else {
            self.view.isUserInteractionEnabled = true
            self.messageFrame.removeFromSuperview()
            self.activityIndicator.stopAnimating()
            self.refreshControl.endRefreshing()
            print("Internet Connection not Available!")
        }
    }
    
    func loadingData() {
        messageFrame.frame = CGRect(x: 90, y: 150 , width: 50, height: 50)
        messageFrame.layer.cornerRadius = 10
        messageFrame.backgroundColor = UIColor.black
        messageFrame.alpha = 0.7
        
        activityIndicator.color = UIColor.white
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
        // Design Button Pest
        buttonPest.backgroundColor = UIColor.white
        buttonPest.layer.cornerRadius = 5
        buttonPest.layer.borderWidth = 0
        buttonPest.layer.borderColor = UIColor.lightGray.cgColor
        buttonPest.layer.shadowColor = UIColor.lightGray.cgColor
        buttonPest.layer.shadowOffset = CGSize(width: 0, height: 0)
        buttonPest.layer.shadowOpacity = 1.0
        buttonPest.layer.shadowRadius = 5.0
        buttonPest.layer.masksToBounds = false
    }
}

extension UltraKlinHomeView : UICollectionViewDelegate, UICollectionViewDataSource {
    //1
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //2
    func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return serviceArray.count
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! CollectionViewCell
        cell.serviceImage.image = serviceArray[indexPath.row].serviceimage
        cell.serviceTitle.text = serviceArray[indexPath.row].serviceName
        
        if heightcell == Int(itemsPerRow) {
            self.constraintCollectionView.constant += CGFloat((self.widthPerItem + 50 + Int(self.sectionInsets.top + self.sectionInsets.bottom)))
            heightcell = 1
            print(heightcell)
        } else {
            heightcell += 1
            print(heightcell)
        }
        cell.layer.backgroundColor = UIColor.white.cgColor
        cell.layer.cornerRadius = 5
        cell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.layer.shadowOpacity = 1.0
        cell.layer.shadowRadius = 5.0
        cell.layer.masksToBounds = false
        return cell
    }
}

extension UltraKlinHomeView : UICollectionViewDelegateFlowLayout {
    
    //1
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        //2
        //let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        //let availableWidth = view.frame.width - paddingSpace
        //let widthPerItem = availableWidth / itemsPerRow
        //collectionView.frame.size.height = widthPerItem + 50 + sectionInsets.top + sectionInsets.bottom
        return CGSize(width: widthPerItem, height: widthPerItem + 50)
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
