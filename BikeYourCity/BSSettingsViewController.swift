//
//  BSSettingsViewController.swift
//  BikeYourCity
//
//  Created by Dacio Leal Rodriguez on 18/6/16.
//  Copyright © 2016 Dacio Leal Rodriguez. All rights reserved.
//

import UIKit
import CoreData

class BSSettingsViewController: UIViewController {
    
    
    let networkManager = BSNetworkManager.manager
    let moc = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)

    override func viewDidLoad() {
        super.viewDidLoad()

        moc.persistentStoreCoordinator = networkManager.psc
        
        let fetch = NSFetchRequest(entityName: "BSRoute")
        do {
            
            let routes = try moc.executeFetchRequest(fetch) as? [BSRoute]
            
            if routes?.count > 0 {
                
                for route in routes! {
                    
                    let polyLine = route.polyLineRoute()
                    print("PolyLine points: \(polyLine?.points())")
                    
                }
                
                
            }
            
            
        } catch let error as NSError {
             print("Error: \(error.description)")
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
