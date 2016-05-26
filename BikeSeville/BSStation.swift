//
//  BSStation.swift
//  BikeSeville
//
//  Created by Dacio Leal Rodriguez on 21/5/16.
//  Copyright © 2016 Dacio Leal Rodriguez. All rights reserved.
//

import Foundation
import CoreData
import MapKit


class BSStation: NSManagedObject, MKAnnotation {

// Insert code here to add functionality to your managed object subclass
    
    var coordinate: CLLocationCoordinate2D {
        
        get {
            var coord = CLLocationCoordinate2D()
            
            if let lat = self.position_lat?.doubleValue {
                coord.latitude = lat
            }
            
            if let long = self.position_long?.doubleValue {
                coord.longitude = long
            }
            
            return coord
        }
    }
    
    var title: String? {
        
        get {
            if let name = self.name {
                return name
            }
            return nil
        }
    }
    
    var subtitle: String? {
        
        get {
            var subtitle = String()
            if let bikes = self.available_bikes?.integerValue {
                subtitle = subtitle.stringByAppendingString("Bikes:\(bikes)")
            }
            if let stands = self.available_bike_stands?.integerValue {
                subtitle = subtitle.stringByAppendingString(" Stands:\(stands)")
            }
            if let total = self.bike_stands?.integerValue {
                subtitle = subtitle.stringByAppendingString(" Total:\(total)")
            }
            return subtitle
        }
        
    }

}
