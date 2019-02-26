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

    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var previousLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        checkLocationServices()
        mapView.delegate = self
        mapView.showsUserLocation = true
//        locationManager.requestAlwaysAuthorization() don't need this probably
        locationManager.requestWhenInUseAuthorization()
        
        
    }
    
    func setupUI() {
        let backButtonImage = UIImage(named: "terug_normal")!
        self.navigationController?.navigationBar.tintColor = UIColor(red: 188/255, green: 211/255, blue: 3/255, alpha: 1)
        self.navigationController?.navigationBar.backIndicatorImage = backButtonImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = backButtonImage
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            previousLocation = locationManager.location
            if let previousLocation = previousLocation {
                updateAddress(location: previousLocation)
            }
        case .denied:
            // Huston, we have problem
            // They have to enable in settings -> show the way
            presentWarningAlert(message: "Please enable tracking location in your settings")
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // show an alert
            presentWarningAlert(message: "This app is not authorized to use location services.")
        case .authorizedAlways:
            break
        }
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            presentWarningAlert(message: "App cannot work without your location. Please enable it.")
        }
    }
    
    func addAnnotation() {
        let usersAnnotaion = MKPointAnnotation()
        usersAnnotaion.title = "User"
        guard let previousLocation = previousLocation else { return }
        usersAnnotaion.coordinate = previousLocation.coordinate
        print("Added annotation")
    }
    
    @IBAction func callButtonPressed(_ sender: Any) {
        let phoneNumber = 9007788990
        guard let url = URL(string: "tel://+31\(phoneNumber)") else { return }
        UIApplication.shared.open(url)
    }
    
    func updateAddress(location: CLLocation) {
    
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(location) { (placemark, error) in
            if let err = error {
                print("Error in reverse geocode location: \(err.localizedDescription)")
            }
            
            guard let placemark = placemark?.first else {
                // alert
                return
            }
            
            let streetNumber = placemark.thoroughfare
            let city = placemark.locality
            let country = placemark.country
            let postalCode = placemark.postalCode
            print("🏠 Street: \(streetNumber)")
            print("🏠 Country: \(country)")
            print("🏠 City: \(city)")
            print("🏠 Postal code: \(postalCode)")
    
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last  else { return }
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, latitudinalMeters: 1000, longitudinalMeters: 1000)
        self.mapView.setRegion(region, animated: true)
        
        if let previousLocation = previousLocation {
            
            if location.distance(from: previousLocation) > 50 {
                updateAddress(location: location)
                self.previousLocation = location
                if mapView.annotations.count == 0 {
                    addAnnotation()
                } else {
                    let allAnnotations = mapView.annotations
                    mapView.removeAnnotations(allAnnotations)
                    addAnnotation()
                }
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

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "anotationView")
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "anotationView")
        }
        
        annotationView?.image = UIImage(named: "address_back")
        
        return annotationView
    }
    
}
