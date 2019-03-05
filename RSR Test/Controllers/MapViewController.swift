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
    @IBOutlet weak var showPopupButton: UIButton!
    @IBOutlet weak var showPopupPhoneImageView: UIImageView!
    @IBOutlet weak var popupView: UIView!
    
    let locationManager = CLLocationManager()
    var lastLocation: CLLocation?
    let userAnnotation = AddressAnnotation()
    var address = Address(streetName: "", city: "", postalCode: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupMapViewDelegate()
        checkLocationServices()
    }
    
    @objc func backButtonPressed(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //    MARK: - UI methods
    
    func setupUI() {
        let backButton = UIBarButtonItem(image: UIImage(named: "terug_normal"), style: .plain, target: self, action: #selector(backButtonPressed(sender:)))
        backButton.tintColor = UIColor(red: 188/255, green: 211/255, blue: 3/255, alpha: 1)
        self.navigationItem.leftBarButtonItem = backButton
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.popupView.alpha = 0
        }
    }
    
    //    MARK: - Popup
    
    func popupToggle(hide: Bool) {
        guard UIDevice.current.userInterfaceIdiom == .phone else { return }
        
        UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseInOut, animations: {
            if hide {
                self.popupView.alpha = 0
                self.showPopupButton.alpha = 1
                self.showPopupPhoneImageView.alpha = 1
            } else {
                self.mapView.deselectAnnotation(self.userAnnotation, animated: true)
                self.mapView.removeAnnotation(self.userAnnotation)
                self.popupView.alpha = 1
                self.showPopupButton.alpha = 0
                self.showPopupPhoneImageView.alpha = 0
            }
        }) { (success) in
            if hide {
                self.mapView.addAnnotation(self.userAnnotation)
                self.mapView.selectAnnotation(self.userAnnotation, animated: true)
            }
        }
        
    }
    
    @IBAction func showPopupButtonPressed(_ sender: Any) {
        popupToggle(hide: false)
    }
    
    @IBAction func callButtonPressed(_ sender: Any) {
        popupToggle(hide: true)
        makeCall()
    }
    
    @IBAction func cancelPopupButtonPressed(_ sender: Any) {
        popupToggle(hide: true)
    }
    
    func makeCall() {
        let phoneNumber = 9007788990
        guard let url = URL(string: "tel://+31\(phoneNumber)") else { return }
        UIApplication.shared.open(url)
    }
    
    
    //    MARK: - Map UI methods
    
    func setupMapViewDelegate() {
        mapView.delegate = self
        mapView.showsUserLocation = false
    }
    
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
            presentLocationPermissionAlert()
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
            presentLocationPermissionAlert()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            presentLocationPermissionAlert()
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
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
            let streetName = placemark.name
            print("name: \(placemark.name), th: \(placemark.thoroughfare)")
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
        }
        return ""
    }
    
    func updateAddress() {
        if ConnectionManager.shared.isConnected() {
            guard let location = lastLocation else { return }
            
            getAddress(location: location) {
                self.userAnnotation.address = self.address
                self.userAnnotation.coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                self.updateCallout()
                self.setRegion(location: location)
            }
        } else {
            presentConnectionAlert()
        }
    }
    
    //    MARK: - Alerts
    
    func presentLocationPermissionAlert() {
        let alert = UIAlertController(title: "Location Permission", message: "Please authorize RSR to find your location while using the app", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (action) in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    if !success {
                        print("error while opening settings")
                    }
                })
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        
        present(alert,animated: true, completion: nil)
    }
    
    func presentConnectionAlert() {
        let alert = UIAlertController(title: "Internet error", message: "Unable to locate your address. Please check your internet connection", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let retryAction = UIAlertAction(title: "Retry", style: .default) { (action) in
            self.updateAddress()
        }
        alert.addAction(cancelAction)
        alert.addAction(retryAction)
        present(alert, animated: true, completion: nil)
    }
    
    

}

// MARK: - Location Manager delegate methods

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last  else { return }
        
        if let previousLocation = lastLocation {
        
            if location.distance(from: previousLocation) > 20 {
                self.lastLocation = location
                self.updateAddress()
            }
            
        } else {
            userAnnotation.coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            self.mapView.addAnnotation(self.userAnnotation)
            self.mapView.selectAnnotation(self.userAnnotation, animated: true)
            self.lastLocation = location
            self.updateAddress()
            setRegion(location: location)
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
            calloutView.addressLabel.text = getStringAddress(address: address)
        }
        calloutView.center = CGPoint(x: view.bounds.size.width / 2, y: -calloutView.bounds.size.height*0.52)
        view.addSubview(calloutView)
        mapView.setCenter((view.annotation?.coordinate)!, animated: true)
        
    }
    
    // didDeselect method is used for updating callout
    // selectAnnotation "disables" user to hide callout
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.isKind(of: AddressAnnotationView.self) {
            for subview in view.subviews {
                subview.removeFromSuperview()
            }
        }
        self.mapView.selectAnnotation(userAnnotation, animated: false)
    }
    
}
