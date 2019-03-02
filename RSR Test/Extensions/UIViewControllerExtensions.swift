//
//  UIViewControllerExtensions.swift
//  RSR Test
//
//  Created by Ráchel Polachová on 26/02/2019.
//  Copyright © 2019 Rachel Polachova. All rights reserved.
//

import Foundation
import UIKit
import MapKit

extension UIViewController {
    
    func presentPermissionAlert() {
        let alert = UIAlertController(title: "Location Permission", message: "Please authorize RSR to find your location while using the app", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (action) in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)")
                })
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        
        present(alert,animated: true, completion: nil)
    }
}

