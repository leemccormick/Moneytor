//
//  PinLocation+Convenience.swift
//  Moneytor
//
//  Created by Lee McCormick on 3/11/21.
//

import CoreData
import MapKit

extension PinLocation {
    
    @discardableResult convenience init(latitude: Double, longitude: Double, context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.init(context: context)
        self.latitude = latitude
        self.longitude = longitude
    }
}
