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
    let backButton = UIBarButtonItem(image: UIImage(named: "terug_normal"), style: .plain, target: self, action: #selector(backButtonPressed(sender:)))

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        mapView.delegate = self
        mapView.showsUserLocation = true
        checkLocationServices()
//        locationManager.requestWhenInUseAuthorization()
        showPopup(isHidden: true)
    }
    
    @objc func backButtonPressed(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //    MARK: - UI methods
    
    func setupUI() {
        backButton.tintColor = UIColor(red: 188/255, green: 211/255, blue: 3/255, alpha: 1)
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    func showPopup(isHidden: Bool) {
        if UIDevice.current.userInterfaceIdiom == .phone {
            mapView.showsUserLocation = isHidden
            
            popupBack.isHidden = isHidden
            callButton.isHidden = isHidden
            popupPhoneImageView.isHidden = isHidden
            popupTitle.isHidden = isHidden
            popupDescription.isHidden = isHidden
            cancelPopupButton.isHidden = isHidden
            
            showPopupButton.isHidden = !isHidden
            showPopupPhoneImageView.isHidden = !isHidden
        }
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
            setupFirstView()
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
    
/**
     Set previous location as current location and set region
 */
    func setupFirstView() {
        
        previousLocation = locationManager.location
        if let previousLocation = previousLocation {
            updateAddress(location: previousLocation)
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: previousLocation.coordinate.latitude, longitude: previousLocation.coordinate.longitude), latitudinalMeters: 300, longitudinalMeters: 300)
            self.mapView.setRegion(region, animated: true)
        }
        
    }
    
    
/**
     Get address from geoCoder and post notification so annotation view can be updated.
 */
    func updateAddress(location: CLLocation) {
        print("update called")
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location) { (placemark, error) in
            if let err = error {
                print("Error in reverse geocode location: \(err.localizedDescription)")
            }
            
            guard let placemark = placemark?.first else { return }
            
            let streetNumber = placemark.thoroughfare
            let city = placemark.locality
            let country = placemark.country
            let postalCode = placemark.postalCode
            
            let userInfo = ["streetName": streetNumber, "country": country, "city": city, "postalCode": postalCode]
            
            NotificationCenter.default.post(Notification(name: .didReceiveData, object: self, userInfo: userInfo as [AnyHashable : Any]))
        }
        
    }
    
    @IBAction func showPopupButtonPressed(_ sender: Any) {
        showPopup(isHidden: false)
    }
    
    @IBAction func callButtonPressed(_ sender: Any) {
        if let previousLocation = previousLocation {
            updateAddress(location: previousLocation)
        }
        showPopup(isHidden: true)
        
        let phoneNumber = 9007788990
        guard let url = URL(string: "tel://+31\(phoneNumber)") else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func cancelPopupButtonPressed(_ sender: Any) {
        if let previousLocation = previousLocation {
            updateAddress(location: previousLocation)
        }
        showPopup(isHidden: true)
    }
}

// MARK: - Location Manager delegate methods

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last  else { return }
        if let previousLocation = previousLocation {
            if location.distance(from: previousLocation) > 50 {
                updateAddress(location: location)
                let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), latitudinalMeters: 300, longitudinalMeters: 300)
                self.mapView.setRegion(region, animated: true)
                self.previousLocation = location
            }
        } else {
            previousLocation = location
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
        
        let pin = AddressView(annotation: annotation, reuseIdentifier: "LocationInfo")
        pin.canShowCallout = false
        return pin
    }
    
}
