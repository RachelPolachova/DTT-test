//
//  CustomCallout.swift
//  RSR Test
//
//  Created by Ráchel Polachová on 27/02/2019.
//  Copyright © 2019 Rachel Polachova. All rights reserved.
//

import UIKit
import MapKit

class CustomCallout: MKAnnotationView {

    var streetLabel: UILabel = {
        let label = UILabel()
        label.text = "blah"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.addSubview(streetLabel)
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayout() {
        self.streetLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.streetLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
