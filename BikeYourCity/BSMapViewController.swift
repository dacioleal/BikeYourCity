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
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}



class BSMapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var latitudeLabel: UILabel!
    @IBOutlet var longitudeLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var speedLabel: UILabel!
    @IBOutlet var kmLabel: UILabel!
    @IBOutlet var timerView: UIView!
    @IBOutlet var clockButton: UIBarButtonItem!
    
    var timer: Timer?
    var startTime: Date?
    var route : BSRoute?
    var counter = 1.0
    
    let locationManager = CLLocationManager()
    
    let networkManager = BSNetworkManager.manager
    let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    var stations = [BSStation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        moc.persistentStoreCoordinator = networkManager.psc
        
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.distanceFilter = 5
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        //updateStationsFromServer()
        
        let location = CLLocation(latitude: 37.39592265, longitude: -5.98225566) //Seville Centre
        
        let viewRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 8000, 8000)
        let adjustedRegion = mapView.regionThatFits(viewRegion)
        mapView.setRegion(adjustedRegion, animated: true)
        mapView.delegate = self

    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
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
    
    
    @IBAction func updateAction(_ sender: UIBarButtonItem) {
        
        updateStationsFromServer()
    }
    
    @IBAction func startClockAction(_ sender: UIBarButtonItem) {
        
        let privateMOC = networkManager.privateMOC
        
        if timer?.isValid == true {
            timer?.invalidate()
            timer = nil
            let clockStartImage = UIImage(named: "clock_start_icon")
            if let image = clockStartImage {
                clockButton.image = image
            }
            
            //Guardamos el tiempo de parada de la ruta
            privateMOC.performAndWait {
                
                
                do {
                    try privateMOC.save()
                } catch let error as NSError {
                    print("Error: \(error.description)")
                }
            }
            startTime = nil;
            counter = 1.0
            
        } else {
            
            startTime = Date()
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(BSMapViewController.timerAction), userInfo: nil, repeats: true)
            let clockStopImage = UIImage(named: "clock_stop_icon")
            if let image = clockStopImage {
                clockButton.image = image
            }
            
            //Creamos una nueva ruta y la guardamos
            var routeID :NSManagedObjectID?
            privateMOC.performAndWait {
                let route = NSEntityDescription.insertNewObject(forEntityName: "BSRoute", into: privateMOC) as? BSRoute
                route?.startDate = self.startTime
                do {
                    try privateMOC.save()
                } catch let error as NSError {
                    print("Error: \(error.description)")
                }
                if let routeIn = route {
                    routeID = routeIn.objectID
                }
            }
            
            if let routeMoID = routeID {
                self.route = moc.object(with: routeMoID) as? BSRoute
                do {
                    try moc.save()
                } catch let error as NSError {
                    print("Error: \(error.description)")
                }
            }
        }
    }
    
    func timerAction() {
        
        if let date = startTime {
            
            let currentDate = Date(timeInterval: counter, since: date)
            let difference = currentDate.timeIntervalSince(date)
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
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let lastLocation = locations.last
        
        if timer?.isValid == true {
            
            let privateMOC = networkManager.privateMOC
            privateMOC.perform {
                let point = NSEntityDescription.insertNewObject(forEntityName: "BSPoint", into: privateMOC) as? BSPoint
                point?.latitude = lastLocation?.coordinate.latitude as NSNumber?
                point?.longitude = lastLocation?.coordinate.longitude as NSNumber?
                point?.course = lastLocation?.course as NSNumber?
                point?.speed = lastLocation?.speed as NSNumber?
                point?.timeStamp = lastLocation?.timestamp
                
                if let routeIn = self.route {
                    let route = privateMOC.object(with: routeIn.objectID) as! BSRoute
                    point?.route = route
                }
                
                do {
                    try privateMOC.save()
                } catch let error as NSError {
                    print("Error: \(error.description)")
                }
            }
        }
        
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
    
    //MARK: Stations related methods
    
    func updateStationsFromServer() {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let contractsOperation = BSContractInfoOperation(contract: Constants.kContractSeville)
        networkManager.queue?.addOperation(contractsOperation)
        
        let stationsOperation = BSStationsForContractOperation(contract: Constants.kContractSeville)
        stationsOperation.addDependency(contractsOperation)
        networkManager.queue?.addOperation(stationsOperation)
        
        let delay = 2.5 * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time) {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.loadStations()
            self.displayStationsOnMap()
        }
        
    }
    
    
    func loadStations() {
        
        let fetch = NSFetchRequest<BSContract>(entityName: "BSContract")
        let predicate = NSPredicate(format: "name = %@", Constants.kContractSeville)
        fetch.predicate = predicate
        
        do {
            let results = try self.moc.fetch(fetch)
            if results.count > 0 {
                let contract:BSContract? = results.first 
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
    }
    
    //MARK: MapView delegate methods
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay.isKind(of: MKPolyline.self) {
            let polyLineRenderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
            polyLineRenderer.fillColor = UIColor.green
            polyLineRenderer.strokeColor = UIColor.yellow
            polyLineRenderer.lineWidth = 2.0
            return polyLineRenderer
        }
        return MKPolylineRenderer()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if (annotation.coordinate.latitude == mapView.userLocation.coordinate.latitude) && (annotation.coordinate.longitude == mapView.userLocation.coordinate.longitude) {
            return nil   //For user current location don't use custom view use default view
        }
        
        let station = annotation as! BSStation
        let numberToShow = station.available_bikes?.intValue
        
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "annotationIdentifier")
        annotationView.image = BSAnnotationImage(numberToShow: numberToShow!, status:station.stationAvailabilityForBikes())
        annotationView.canShowCallout = true
        
        return annotationView
    }

}
