//
//  BSCity+CoreDataProperties.swift
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

extension BSCity {

    @NSManaged var name: String?
    @NSManaged var contract: NSManagedObject?

}
