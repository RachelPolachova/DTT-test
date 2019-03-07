//
//  Address.swift
//  RSR Test
//
//  Created by Ráchel Polachová on 02/03/2019.
//  Copyright © 2019 Rachel Polachova. All rights reserved.
//

import Foundation

struct Address {
    var streetName: String
    var city: String
    var postalCode: String
    
    init(streetName: String, city: String, postalCode: String) {
        self.streetName = streetName
        self.city = city
        self.postalCode = postalCode
    }
    
    func getString() -> String {
        return "\(self.streetName), \(self.postalCode), \(self.city)"
    }
}
