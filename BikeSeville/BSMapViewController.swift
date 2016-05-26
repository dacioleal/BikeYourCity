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
    let moc = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    var stations = [BSStation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        moc.persistentStoreCoordinator = networkManager.psc
        
        self.title = "Map"
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.distanceFilter = 5
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        let contractsOperation = BSContractInfoOperation(contract: Constants.kContractSeville)
        networkManager.queue?.addOperation(contractsOperation)
        
        
        let stationsOperation = BSStationsForContractOperation(contract: Constants.kContractSeville)
        stationsOperation.addDependency(contractsOperation)
        networkManager.queue?.addOperation(stationsOperation)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let delay = 1.5 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            self.loadStations()
            self.displayStationsOnMap()
        }
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
        
        let viewRegion = MKCoordinateRegionMakeWithDistance((lastLocation?.coordinate)!, 1000, 1000)
        let adjustedRegion = mapView.regionThatFits(viewRegion)
        mapView.setRegion(adjustedRegion, animated: true)
        
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
    
    func loadStations() {
        
        let fetch = NSFetchRequest(entityName: "BSContract")
        let predicate = NSPredicate(format: "name = %@", Constants.kContractSeville)
        fetch.predicate = predicate
        
        do {
            let results = try self.moc.executeFetchRequest(fetch)
            if results.count > 0 {
                let contract = results.first as? BSContract
                let contractStations = contract?.stations?.allObjects as? [BSStation]
                if contractStations?.count > 0 {
                    self.stations = contractStations!
                }
            }
            
        } catch let error as NSError {
            print("Error: \(error.description)")
        }

    }
    
    func displayStationsOnMap() {
        
        mapView.addAnnotations(stations)
        print("Stations count:\(stations.count)")
    }

}
