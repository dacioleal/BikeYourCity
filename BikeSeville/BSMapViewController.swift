//
//  BSMapViewController.swift
//  BikeSeville
//
//  Created by Dacio Leal Rodriguez on 14/5/16.
//  Copyright © 2016 Dacio Leal Rodriguez. All rights reserved.
//

import UIKit
import MapKit
import CoreData


class BSMapViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var latitudeLabel: UILabel!
    @IBOutlet var longitudeLabel: UILabel!
    @IBOutlet var speedLabel: UILabel!
    
    
    let locationManager = CLLocationManager()
    
    let networkManager = BSNetworkManager.manager
    let moc = BSNetworkManager.manager.privateMOC
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Map"
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.distanceFilter = 5
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
//        let contract = NSEntityDescription.insertNewObjectForEntityForName("BSContract", inManagedObjectContext: moc) as! BSContract
//        contract.country_code = "FR"
//        contract.commercial_name = "Velo"
//        contract.name = "Paris"
//        save()
        
        let contractsOperation = BSContractInfoOperation(contract: Constants.kContractSeville)
        networkManager.queue?.addOperation(contractsOperation)
        
        let stationsOperation = BSStationsForContractOperation(contract: Constants.kContractSeville)
        networkManager.queue?.addOperation(stationsOperation)
        stationsOperation.addDependency(contractsOperation)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let lastLocation = locations.last
        
        if lastLocation != nil {
            
            let latitudeStr = String(format: "Lat: %.8f", (lastLocation?.coordinate.latitude)!)
            let longitudeStr = String(format: "Long: %.8f", (lastLocation?.coordinate.longitude)!)
            let speed = (lastLocation?.speed)! * 3600 / 1000  // Km/h conversion
            let speedStr = String(format: "Speed: %.8f km/h", speed)
            
            latitudeLabel.text = latitudeStr
            longitudeLabel.text = longitudeStr
            speedLabel.text = speedStr
        }
        
    }
    
    func save() {
        
        do {
            try moc.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }

}
