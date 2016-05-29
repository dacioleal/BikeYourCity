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
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var speedLabel: UILabel!
    @IBOutlet var kmLabel: UILabel!
    @IBOutlet var timerView: UIView!
    @IBOutlet var clockButton: UIBarButtonItem!
    
    var timer: NSTimer?
    var startTime: NSDate?
    var counter = 1.0
    
    let locationManager = CLLocationManager()
    
    let networkManager = BSNetworkManager.manager
    let moc = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    var stations = [BSStation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        moc.persistentStoreCoordinator = networkManager.psc
        
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.distanceFilter = 5
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        updateStationsFromServer()
        
        let location = CLLocation(latitude: 37.39592265, longitude: -5.98225566) //Seville Centre
        
        let viewRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 8000, 8000)
        let adjustedRegion = mapView.regionThatFits(viewRegion)
        mapView.setRegion(adjustedRegion, animated: true)
        
        
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    @IBAction func updateAction(sender: UIBarButtonItem) {
        
        updateStationsFromServer()
    }
    
    @IBAction func startClockAction(sender: UIBarButtonItem) {
        
        if timer?.valid == true {
            timer?.invalidate()
            timer = nil
            let clockStartImage = UIImage(named: "clock_start_icon")
            if let image = clockStartImage {
                clockButton.image = image
            }
            startTime = nil;
            counter = 1.0
        } else {
            
            startTime = NSDate()
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(BSMapViewController.timerAction), userInfo: nil, repeats: true)
            let clockStopImage = UIImage(named: "clock_stop_icon")
            if let image = clockStopImage {
                clockButton.image = image
            }
            
        }
    }
    
    func timerAction() {
        
        if let date = startTime {
            
            let currentDate = NSDate(timeInterval: counter, sinceDate: date)
            let difference = currentDate.timeIntervalSinceDate(date)
            var differenceInteger = NSInteger(difference)
            
            let hours = differenceInteger / 3600
            differenceInteger -= hours * 3600
            let minutes = differenceInteger / 60
            differenceInteger -= minutes * 60
            let seconds = differenceInteger
            
            print("\(hours):\(minutes):\(seconds)")
            timeLabel.text = "\(hours):\(minutes):\(seconds)"
            
            counter += 1.0
        }
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let lastLocation = locations.last
        
        if lastLocation != nil {
            
            let latitudeStr = String(format: "Lat: %.8f", (lastLocation?.coordinate.latitude)!)
            let longitudeStr = String(format: "Long: %.8f", (lastLocation?.coordinate.longitude)!)
            let speed = (lastLocation?.speed)! * 3600 / 1000  // Km/h conversion
            let speedStr = String(format: "%.2f km/h", speed)
            
            latitudeLabel.text = latitudeStr
            longitudeLabel.text = longitudeStr
            speedLabel.text = speedStr
            
            if speed > 2.0 {
                
                let viewRegion = MKCoordinateRegionMakeWithDistance((lastLocation?.coordinate)!, 1000, 1000)
                let adjustedRegion = mapView.regionThatFits(viewRegion)
                mapView.setRegion(adjustedRegion, animated: true)
            }
            
        }
        
    }
    
    
    func updateStationsFromServer() {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let contractsOperation = BSContractInfoOperation(contract: Constants.kContractSeville)
        networkManager.queue?.addOperation(contractsOperation)
        
        let stationsOperation = BSStationsForContractOperation(contract: Constants.kContractSeville)
        stationsOperation.addDependency(contractsOperation)
        networkManager.queue?.addOperation(stationsOperation)
        
        let delay = 2.5 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.loadStations()
            self.displayStationsOnMap()
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
        
        if mapView.annotations.count > 0 {
            mapView.removeAnnotations(mapView.annotations)
        }
        mapView.showAnnotations(stations, animated: true)
        print("Stations count:\(stations.count)")
        print("Map annotations: \(mapView.annotations.count)")
        
        
        
    }

}