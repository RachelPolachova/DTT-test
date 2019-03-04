//
//  MapViewController.swift
//  RSR Test
//
//  Created by Ráchel Polachová on 26/02/2019.
//  Copyright © 2019 Rachel Polachova. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MapViewController: UIViewController {

    
    @IBOutlet weak var popupBack: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var popupPhoneImageView: UIImageView!
    @IBOutlet weak var popupTitle: UILabel!
    @IBOutlet weak var popupDescription: UILabel!
    @IBOutlet weak var cancelPopupButton: UIButton!
    @IBOutlet weak var showPopupButton: UIButton!
    @IBOutlet weak var showPopupPhoneImageView: UIImageView!
    
    let locationManager = CLLocationManager()
    var previousLocation: CLLocation?
    let userAnnotation = AddressAnnotation()
    var address = Address(streetName: "", city: "", postalCode: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        mapView.delegate = self
        mapView.showsUserLocation = true
        checkLocationServices()
        mapView.showsUserLocation = false
        popupToggle(hide: true)
    }
    
    @objc func backButtonPressed(sender: UIBarButtonItem) {
        print("back button pressed")
        self.navigationController?.popViewController(animated: true)
    }
    
    //    MARK: - UI methods
    
    func setupUI() {
        let backButton = UIBarButtonItem(image: UIImage(named: "terug_normal"), style: .plain, target: self, action: #selector(backButtonPressed(sender:)))
        backButton.tintColor = UIColor(red: 188/255, green: 211/255, blue: 3/255, alpha: 1)
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    //    MARK: - Popup
    
    @IBAction func showPopupButtonPressed(_ sender: Any) {
        popupToggle(hide: false)
    }
    
    @IBAction func callButtonPressed(_ sender: Any) {
        popupToggle(hide: true)
        
        let phoneNumber = 9007788990
        guard let url = URL(string: "tel://+31\(phoneNumber)") else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func cancelPopupButtonPressed(_ sender: Any) {
        popupToggle(hide: true)
    }
    
    func popupToggle(hide: Bool) {
        if UIDevice.current.userInterfaceIdiom == .phone {
            
            if hide {
                mapView.addAnnotation(userAnnotation)
                mapView.selectAnnotation(userAnnotation, animated: true)
            } else {
                mapView.deselectAnnotation(userAnnotation, animated: true)
                mapView.removeAnnotation(userAnnotation)
            }
            
            popupBack.isHidden = hide
            callButton.isHidden = hide
            popupPhoneImageView.isHidden = hide
            popupTitle.isHidden = hide
            popupDescription.isHidden = hide
            cancelPopupButton.isHidden = hide
            
            showPopupButton.isHidden = !hide
            showPopupPhoneImageView.isHidden = !hide
        }
    }
    
    //    MARK: - Map UI methods
    
    func setRegion(location: CLLocation) {
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), latitudinalMeters: 300, longitudinalMeters: 300)
        self.mapView.setRegion(region, animated: true)
    }
    
    func updateCallout() {
        self.mapView.deselectAnnotation(userAnnotation, animated: false)
    }
    
    //    MARK: - Location Manager methods
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            presentPermissionAlert()
        }
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
            
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .denied:
            presentPermissionAlert()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            presentPermissionAlert()
        case .authorizedAlways:
            break
        }
    }
    
    //    MARK: - Address methods
    
    func getAddress(location: CLLocation, completion: @escaping ()->()) {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location) { (placemark, error) in
            if let err = error {
                print("Error in reverse geocode locaction: \(err.localizedDescription)")
            }
            guard let placemark = placemark?.first else { return }
            let streetName = placemark.thoroughfare
            let city = placemark.locality
            let postalCode = placemark.postalCode
            self.address.streetName = streetName ?? ""
            self.address.city = city ?? ""
            self.address.postalCode = postalCode ?? ""
            completion()
        }
    }
    
    func getStringAddress(address: Address?) -> String {
        if let address = address {
            return "\(address.streetName), \(address.postalCode), \(address.city)"
        } else {
            return ""
        }
    }

}

// MARK: - Location Manager delegate methods

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last  else { return }
        
        if let previousLocation = previousLocation {
        
            if location.distance(from: previousLocation) > 10 {
                getAddress(location: location) {
                    self.userAnnotation.address = self.address
                    self.userAnnotation.coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                    self.setRegion(location: location)
                    self.updateCallout()
                }
                self.previousLocation = location
            }
        } else {
            
            userAnnotation.coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            self.mapView.addAnnotation(self.userAnnotation)
            self.mapView.selectAnnotation(self.userAnnotation, animated: true)
            getAddress(location: location) {
                self.userAnnotation.address = self.address
                self.updateCallout()
            }
            setRegion(location: location)
            self.previousLocation = location
        }
        
}
    
    // user may change authorization in settings
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
}

// MARK: - MapView Delegate methods

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: "pin")
        if annotationView == nil {
            annotationView = AddressAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            annotationView?.canShowCallout = false
            annotationView?.image = UIImage(named: "marker")
        } else {
            annotationView?.annotation = annotation
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.annotation is MKUserLocation {
            return
        }
        let addressAnnotation = view.annotation as! AddressAnnotation
        let views = Bundle.main.loadNibNamed("AddressCallout", owner: nil, options: nil)
        let calloutView = views?[0] as! AddressCallout
        if let address = addressAnnotation.address {
            print("address is: \(getStringAddress(address: address))")
            calloutView.addressLabel.text = getStringAddress(address: address)
        }
        calloutView.center = CGPoint(x: view.bounds.size.width / 2, y: -calloutView.bounds.size.height*0.52)
        view.addSubview(calloutView)
        mapView.setCenter((view.annotation?.coordinate)!, animated: true)
        
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.isKind(of: AddressAnnotationView.self) {
            for subview in view.subviews {
                subview.removeFromSuperview()
            }
        }
        // cannot really disable didDeselect methods, because thanks to this method, callout is updated.
        // select here is used for showing callout right after disabling it (because updating) and also it "disables" user to hide callout
        self.mapView.selectAnnotation(userAnnotation, animated: false)
    }
    
}
