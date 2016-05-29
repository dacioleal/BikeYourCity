//
//  BSRoute+CoreDataProperties.swift
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

extension BSRoute {

    @NSManaged var startDate: NSDate?
    @NSManaged var stopDate: NSDate?
    @NSManaged var kilometers: NSNumber?
    @NSManaged var time: NSNumber?
    @NSManaged var user: NSManagedObject?
    @NSManaged var points: NSSet?

}
