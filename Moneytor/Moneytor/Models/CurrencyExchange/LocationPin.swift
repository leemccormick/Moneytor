//
//  LocationPin.swift
//  Moneytor
//
//  Created by Lee McCormick on 3/11/21.
//

import Foundation
import MapKit

class LocationPin: MKPointAnnotation {
    var pin: PinLocation
    init(pin: PinLocation){
        self.pin = pin
        super.init()
        self.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
    }
}
