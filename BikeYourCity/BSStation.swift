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
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}



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
            if let bikes = self.available_bikes?.intValue {
                subtitle = subtitle + "Bikes:\(bikes)"
            }
            if let stands = self.available_bike_stands?.intValue {
                subtitle = subtitle + " Stands:\(stands)"
            }
            if let total = self.bike_stands?.intValue {
                subtitle = subtitle + " Total:\(total)"
            }
            return subtitle
        }
        
    }
    
    func stationAvailabilityForBikes() -> StationStatus {
        
        let percentage : Double = (self.available_bikes?.doubleValue)! / (self.bike_stands?.doubleValue)!
        
        var status:StationStatus = StationStatus.stationStatusHighAvailability
        
        if (percentage >= 0.60) {
            status = StationStatus.stationStatusHighAvailability
        } else if (percentage < 0.60 && percentage >= 0.25) {
            status = StationStatus.stationStatusMediumAvailability
        } else if (percentage < 0.25) {
            status = StationStatus.stationStatusLowAvailability
        }
        
        if (self.available_bikes?.intValue >= 5) {
            status = StationStatus.stationStatusHighAvailability
        }
        
        return status
    }
    
    func stationAvailabilityForStands() -> StationStatus {
        let percentage : Double = (self.available_bike_stands?.doubleValue)! / (self.bike_stands?.doubleValue)!
        
        var status:StationStatus = StationStatus.stationStatusHighAvailability
        
        if (percentage >= 0.35) {
            status = StationStatus.stationStatusHighAvailability
        } else if (percentage < 0.35 && percentage >= 0.20) {
            status = StationStatus.stationStatusMediumAvailability
        } else if (percentage < 0.20) {
            status = StationStatus.stationStatusLowAvailability
        }
        
        if (self.available_bike_stands?.intValue >= 5) {
            status = StationStatus.stationStatusHighAvailability
        }
        return status
    }

}
