//
//  BSUser+CoreDataProperties.swift
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

extension BSUser {

    @NSManaged var email: String?
    @NSManaged var gender: String?
    @NSManaged var age: NSNumber?
    @NSManaged var name: String?
    @NSManaged var identifier: NSNumber?
    @NSManaged var routes: NSSet?

}
