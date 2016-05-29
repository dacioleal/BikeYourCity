//
//  BSStation+CoreDataProperties.swift
//  BikeSeville
//
//  Created by Dacio Leal Rodriguez on 21/5/16.
//  Copyright © 2016 Dacio Leal Rodriguez. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension BSStation {

    @NSManaged var number: NSNumber?
    @NSManaged var name: String?
    @NSManaged var address: String?
    @NSManaged var banking: NSNumber?
    @NSManaged var bonus: NSNumber?
    @NSManaged var status: String?
    @NSManaged var bike_stands: NSNumber?
    @NSManaged var available_bike_stands: NSNumber?
    @NSManaged var available_bikes: NSNumber?
    @NSManaged var last_update: NSNumber?
    @NSManaged var position_lat: NSNumber?
    @NSManaged var position_long: NSNumber?
    @NSManaged var contract: BSContract?

}
