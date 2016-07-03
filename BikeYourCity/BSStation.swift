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
    
    func stationAvailabilityForBikes() -> StationStatus {
        
        let percentage : Double = (self.available_bikes?.doubleValue)! / (self.bike_stands?.doubleValue)!
        
        var status:StationStatus = StationStatus.StationStatusHighAvailability
        
        if (percentage >= 0.60) {
            status = StationStatus.StationStatusHighAvailability
        } else if (percentage < 0.60 && percentage >= 0.25) {
            status = StationStatus.StationStatusMediumAvailability
        } else if (percentage < 0.25) {
            status = StationStatus.StationStatusLowAvailability
        }
        
        if (self.available_bikes?.integerValue >= 5) {
            status = StationStatus.StationStatusHighAvailability
        }
        
        return status
    }
    
    func stationAvailabilityForStands() -> StationStatus {
        let percentage : Double = (self.available_bike_stands?.doubleValue)! / (self.bike_stands?.doubleValue)!
        
        var status:StationStatus = StationStatus.StationStatusHighAvailability
        
        if (percentage >= 0.35) {
            status = StationStatus.StationStatusHighAvailability
        } else if (percentage < 0.35 && percentage >= 0.20) {
            status = StationStatus.StationStatusMediumAvailability
        } else if (percentage < 0.20) {
            status = StationStatus.StationStatusLowAvailability
        }
        
        if (self.available_bike_stands?.integerValue >= 5) {
            status = StationStatus.StationStatusHighAvailability
        }
        return status
    }

}
