//
//  GeocoderManager.swift
//  RSR Test
//
//  Created by Ráchel Polachová on 07/03/2019.
//  Copyright © 2019 Rachel Polachova. All rights reserved.
//

import Foundation
import CoreLocation

enum GeocoderManagerErrors: Error {
    case noConnection
}

class GeocoderManager {
    
    /// check if application has access to internet, because CLGeocoder cannot get address without it
    ///
    /// internet conncetion is checked here, so class, where this method is used, doesn't have to care about it.
    /// I think that throw an error is better way how to handle no connection than just return nil
    func getAddress(location: CLLocation, completion: @escaping (_ address: Address)->()) throws {
        let connectionManager = ConnectionManager()
        
        guard connectionManager.isConnected() else {
            throw GeocoderManagerErrors.noConnection
        }
        
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location) { (placemark, error) in
            if let err = error {
                print("Error in reverse geocode locaction: \(err.localizedDescription)")
            }
            guard let placemark = placemark?.first else { return }
            let streetName = placemark.name
            let city = placemark.locality
            let postalCode = placemark.postalCode
            let address = Address(streetName: streetName ?? "", city: city ?? "", postalCode: postalCode ?? "")
            completion(address)
        }
        
    }
    
}
