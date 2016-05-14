//
//  BSNetworkManager.swift
//  BikeSeville
//
//  Created by Dacio Leal Rodriguez on 24/4/16.
//  Copyright © 2016 Dacio Leal Rodriguez. All rights reserved.
//

import Foundation

class BSNetworkManager: NSObject {
    
    static let manager = BSNetworkManager()
    
    let queue: NSOperationQueue?
    
    override init() {
        
        queue = NSOperationQueue()
        super.init()
    }
    
}
