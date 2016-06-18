//
//  BSRoute.swift
//  BikeYourCity
//
//  Created by Dacio Leal Rodriguez on 29/5/16.
//  Copyright © 2016 Dacio Leal Rodriguez. All rights reserved.
//

import Foundation
import CoreData
import MapKit



class BSRoute: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    
    
    func polyLineRoute() -> MKPolyline? {
        
        let points = self.points?.allObjects.sort({ (first, second) -> Bool in
            if first.isKindOfClass(BSPoint) && second.isKindOfClass(BSPoint) {
                let firstPoint = first as! BSPoint
                let secondPoint = second as! BSPoint
                return firstPoint.timeStamp?.timeIntervalSince1970 < secondPoint.timeStamp?.timeIntervalSince1970
            }
            return false;
        })
        print("Points \(points)")
        if let routePoints = points {
            
            var pointsCoordArray : [CLLocationCoordinate2D] = []
            for point in routePoints as! [BSPoint] {
                let pointCoords:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: point.latitude!.doubleValue, longitude: point.longitude!.doubleValue)
                pointsCoordArray.append(pointCoords)
            }
            let polyLine = MKPolyline(coordinates: &pointsCoordArray, count: pointsCoordArray.count)
            return polyLine
        }
        return nil
    }

}
