//
//  googleViewController.swift
//  UltraKlin
//
//  Created by Lini on 02/05/18.
//  Copyright © 2018 PT Lintas Insan Nur Inspira. All rights reserved.
//

import GoogleMaps
import GooglePlaces

protocol PlacePickerDelegate: class {
    func placePicker(picker: GoogleViewController, didPickPlace place: String?)
}

class GoogleViewController : UIViewController {
    
    weak var delegate: PlacePickerDelegate?
    
    private let locationManager = CLLocationManager()
    
    var addressLocation: String?
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var labelAddress: UILabel!
    @IBOutlet private weak var pinImageVerticalConstraint: NSLayoutConstraint!
    @IBOutlet private weak var mapCenterPinImage: UIImageView!
    @IBOutlet weak var buttonDone: UIButton!
    
    @IBAction func searchPlace(_ sender: Any) {
        let placePickerController = GMSAutocompleteViewController()
        placePickerController.delegate = self
        present(placePickerController, animated: true, completion: nil)
    }
    
    @IBAction func buttonDonePlace(_ sender: Any) {
        delegate?.placePicker(picker: self, didPickPlace: addressLocation)
//        let myVC = self.storyboard?.instantiateViewController(withIdentifier: "ultraKlinDetailOrder") as! UltraKlinDetailOrder
//        print(placePicker!)
//        myVC.address = placePicker
//        dismiss(animated: true, completion: nil)
//        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapView.delegate = self
        
        let labelHeight = CGFloat(50) //self.labelAddress.intrinsicContentSize.height
        self.mapView.padding = UIEdgeInsets(top: self.view.layoutMargins.top, left: 0, bottom: labelHeight, right: 0)
        
        UIView.animate(withDuration: 0.25) {
            self.pinImageVerticalConstraint.constant = ((labelHeight - self.view.layoutMargins.top) * 0.5)
            self.view.layoutIfNeeded()
        }
        // Style Button Done
        buttonDone.layer.cornerRadius = 8
        buttonDone.layer.borderWidth = 1
        buttonDone.layer.borderColor = UIColor.white.cgColor
        buttonDone.layer.shadowColor = UIColor.darkGray.cgColor
        buttonDone.layer.shadowOffset = CGSize(width: 0, height: 0)
        buttonDone.layer.shadowOpacity = 1.0
        buttonDone.layer.shadowRadius = 5.0
        buttonDone.layer.masksToBounds = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
        
        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            self.labelAddress.unlock()
            
            guard let address = response?.firstResult(), let lines = address.lines else {
                return
            }
            
            self.addressLocation = lines.joined(separator: ", ")
            self.labelAddress.text = self.addressLocation
            
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
        }
    }
}

extension GoogleViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
            return
        }
        
        locationManager.startUpdatingLocation()
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        
        mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 17, bearing: 0, viewingAngle: 0)
        locationManager.stopUpdatingLocation()
    }
}

extension GoogleViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        reverseGeocodeCoordinate(position.target)
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        labelAddress.lock()
        
        if (gesture) {
            mapCenterPinImage.fadeIn(0.25)
            mapView.selectedMarker = nil
        }
    }
}

extension GoogleViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        mapView.camera = GMSCameraPosition(target: place.coordinate, zoom: 17, bearing: 0, viewingAngle: 0)
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
