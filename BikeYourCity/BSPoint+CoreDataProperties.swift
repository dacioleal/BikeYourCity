//
//  BSPoint+CoreDataProperties.swift
//  BikeYourCity
//
//  Created by Dacio Leal Rodriguez on 29/5/16.
//  Copyright © 2016 Dacio Leal Rodriguez. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension BSPoint {

    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var speed: NSNumber?
    @NSManaged var course: NSNumber?
    @NSManaged var timeStamp: Date?
    @NSManaged var route: BSRoute?

}
