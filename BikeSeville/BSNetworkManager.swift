//
//  BSNetworkManager.swift
//  BikeSeville
//
//  Created by Dacio Leal Rodriguez on 24/4/16.
//  Copyright © 2016 Dacio Leal Rodriguez. All rights reserved.
//

import Foundation
import CoreData

class BSNetworkManager: NSObject {
    
    static let manager = BSNetworkManager()
    
    let queue: NSOperationQueue?
    
    var privateMOC: NSManagedObjectContext
    var psc: NSPersistentStoreCoordinator
    
    
    override init() {
        
        queue = NSOperationQueue()
        queue?.maxConcurrentOperationCount = 1
        
        //CoreData Stack
        
        //Model
        let bundle = NSBundle.mainBundle()
        guard let modelURL = bundle.URLForResource("BSModel", withExtension: "momd") else {
            fatalError("Error loading model from bundle")
        }
        
        guard let model = NSManagedObjectModel(contentsOfURL: modelURL) else {
            fatalError("Error initializing model from: \(modelURL)")
        }
        
        //PersistentStoreCoordinator
        psc = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        //ManagedObjectContext
        privateMOC = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        privateMOC.persistentStoreCoordinator = psc
        
        super.init()
        
        //PersistentStore
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            
            let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
            let docURL = urls[urls.endIndex-1]
            let storeURL = docURL.URLByAppendingPathComponent("BSModel.sqlite")
            print("\(storeURL.absoluteString)")
            
            do {
                try self.psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
            } catch {
                fatalError("Error migrating store: \(error)")
            }
        }
        
    }
    
}
