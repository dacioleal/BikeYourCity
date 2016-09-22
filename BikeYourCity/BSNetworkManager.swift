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
    
    let queue: OperationQueue?
    
    var privateMOC: NSManagedObjectContext
    var psc: NSPersistentStoreCoordinator
    
    
    override init() {
        
        queue = OperationQueue()
        queue?.maxConcurrentOperationCount = 1
        
        //CoreData Stack
        
        //Model
        let bundle = Bundle.main
        guard let modelURL = bundle.url(forResource: "BSModel", withExtension: "momd") else {
            fatalError("Error loading model from bundle")
        }
        
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing model from: \(modelURL)")
        }
        
        //PersistentStoreCoordinator
        psc = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        //ManagedObjectContext
        privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateMOC.persistentStoreCoordinator = psc
        
        super.init()
        
        //PersistentStore
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background).async {
            
            let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let docURL = urls[urls.endIndex-1]
            let storeURL = docURL.appendingPathComponent("BSModel.sqlite")
            print("\(storeURL.absoluteString)")
            
            do {
                try self.psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
            } catch {
                fatalError("Error migrating store: \(error)")
            }
        }
        
    }
    
}
