//
//  AlertManager.swift
//  RSR Test
//
//  Created by Ráchel Polachová on 07/03/2019.
//  Copyright © 2019 Rachel Polachova. All rights reserved.
//

import UIKit

class AlertManager {
    
    func presentLocationPermissionAlert(in viewController: UIViewController) {
        let alert = UIAlertController(title: "Location Permission", message: "Please authorize RSR to find your location while using the app", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (action) in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            
            // open device settings, so user can allow the use of location services for this app
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
        
        viewController.present(alert,animated: true, completion: nil)
    }
    
    // viewController is type UIViewController, because this alert might be used in different VC in future as well
    func presentConnectionAlert(in viewController: UIViewController) {
        let alert = UIAlertController(title: "Internet error", message: "Unable to locate your address. Please check your internet connection", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let retryAction = UIAlertAction(title: "Retry", style: .default) { (action) in
            if let vc = viewController as? MapViewController {
                vc.updateAddress()
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(retryAction)
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func presentAlert(title: String, message: String, in viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(action)
        viewController.present(alert, animated: true, completion: nil)
    }
    
}
