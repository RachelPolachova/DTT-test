//
//  AddressAnnotationView.swift
//  RSR Test
//
//  Created by Ráchel Polachová on 04/03/2019.
//  Copyright © 2019 Rachel Polachova. All rights reserved.
//

import UIKit
import MapKit

class AddressAnnotationView: MKAnnotationView {
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
