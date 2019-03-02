//
//  AddressView.swift
//  RSR Test
//
//  Created by Ráchel Polachová on 27/02/2019.
//  Copyright © 2019 Rachel Polachova. All rights reserved.
//

import UIKit
import MapKit

class AddressView: MKPinAnnotationView {
    
    var back: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "address_back")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var marker: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "marker")
//        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var streetLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var countryLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var cityLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var postalCodeLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.addSubview(marker)
        self.addSubview(back)
        self.addSubview(streetLabel)
        self.addSubview(cityLabel)
        self.addSubview(postalCodeLabel)
        self.addSubview(countryLabel)
        setupLayout()
        NotificationCenter.default.addObserver(self, selector: #selector(updateAdress(_:)), name: NSNotification.Name.didReceiveData, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    @objc func updateAdress(_ notification: Notification) {
        if let data = notification.userInfo {
            if let streetName = data["streetName"] as? String {
                streetLabel.text = streetName
            } else {
                streetLabel.text = ""
            }
            if let city = data["city"] as? String {
                cityLabel.text = city
            } else {
                cityLabel.text = ""
            }
            if let postalCode = data["postalCode"] as? String {
                postalCodeLabel.text = postalCode
            } else {
                postalCodeLabel.text = ""
            }
            if let country = data["country"] as? String {
                countryLabel.text = country
            } else {
                countryLabel.text = ""
            }
        }
    }
    
    
    func setupLayout() {
        marker.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        marker.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        back.centerXAnchor.constraint(equalTo: marker.centerXAnchor, constant: -7).isActive = true
        back.bottomAnchor.constraint(equalTo: marker.topAnchor, constant: -10).isActive = true
        streetLabel.centerXAnchor.constraint(equalTo: back.centerXAnchor).isActive = true
        streetLabel.topAnchor.constraint(equalTo: back.topAnchor, constant: 10).isActive = true
        cityLabel.centerXAnchor.constraint(equalTo: back.centerXAnchor).isActive = true
        cityLabel.topAnchor.constraint(equalTo: streetLabel.bottomAnchor, constant: 10).isActive = true
        postalCodeLabel.centerXAnchor.constraint(equalTo: back.centerXAnchor).isActive = true
        postalCodeLabel.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: 10).isActive = true
        countryLabel.centerXAnchor.constraint(equalTo: back.centerXAnchor).isActive = true
        countryLabel.topAnchor.constraint(equalTo: postalCodeLabel.bottomAnchor, constant: 10).isActive = true
    }

}
