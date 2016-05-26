//
//  BSStationsForContractOperation.swift
//  BikeSeville
//
//  Created by Dacio Leal Rodriguez on 22/5/16.
//  Copyright © 2016 Dacio Leal Rodriguez. All rights reserved.
//

// This operation gets information of every station given a contract

import UIKit
import CoreData

class BSStationsForContractOperation: NSOperation {
    
    let contractName: String
    var contract: BSContract?
    
    init(contract:String) {
        
        self.contractName = contract
        super.init()
        let moc = BSNetworkManager.manager.privateMOC
        
        moc.performBlockAndWait {
            
            let fetch = NSFetchRequest(entityName: "BSContract")
            let predicate = NSPredicate(format: "name = %@", contract)
            fetch.predicate = predicate
            
            do {
                let results = try moc.executeFetchRequest(fetch)
                if results.count > 0 {
                    self.contract = results.first as? BSContract
                }
            } catch let error as NSError {
                print("Error: \(error.description)")
            }
        }
    }
    
    override func main() {
        
        let urlPath = Constants.kURLServer.stringByAppendingString(Constants.kServiceStations)
        let urlPathWithParams = urlPath + "?apiKey=\(Constants.kAPIKey)" + "&contract=\(contractName)"
        let url = NSURL(string: urlPathWithParams)
        
        let request: NSMutableURLRequest
        
        if let requestURL = url {
            
            request = NSMutableURLRequest(URL: requestURL)
            let authString = "\(Constants.kUserName):\(Constants.kPassword)"
            let authData = authString.dataUsingEncoding(NSUTF8StringEncoding)
            let base64AuthString = authData?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
            let authValue = "Basic \(base64AuthString)"
            request.addValue(authValue, forHTTPHeaderField: "Authorization")
            request.HTTPMethod = "GET"
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) in
                
                if error != nil {
                    print("Error: \(error?.description)")
                    return
                }
                
                //let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                //print("ResponseString: \(responseString)")
                
                do {
                    
                    if let jsonArray = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.AllowFragments) as? NSArray {
                       
                        for dict in jsonArray {
                            
                            let number = dict["number"] as? Int
                            let name = dict["name"] as? String
                            let address = dict["address"] as? String
                            let position = dict["position"] as? Dictionary<String, Double>
                            let lat = position?["lat"]
                            let long = position?["lng"]
                            let banking = dict["banking"] as? Bool
                            let bonus = dict["bonus"] as? Bool
                            let status = dict["status"] as? String
                            let bikeStands = dict["bike_stands"] as? Int
                            let availableBikeStands = dict["available_bike_stands"] as? Int
                            let availableBikes = dict["available_bikes"] as? Int
                            let lastUpdate = dict["last_update"] as? Double
                            
                            let moc = BSNetworkManager.manager.privateMOC
                            moc.performBlock({
                                
                                if let numberAt = number {
                                    
                                    let fetch = NSFetchRequest(entityName: "BSStation")
                                    let predicate = NSPredicate(format: "number = %ld", numberAt)
                                    fetch.predicate = predicate
                                    let station: BSStation
                                    
                                    do {
                                        let results = try moc.executeFetchRequest(fetch) as? [BSStation]
                                        
                                        if results?.count > 0 {
                                            station = results!.first!
                                        } else {
                                            station = NSEntityDescription.insertNewObjectForEntityForName("BSStation", inManagedObjectContext: moc) as! BSStation
                                        }
                                        
                                        station.number = number
                                        station.name = name
                                        station.address = address
                                        station.position_lat = lat
                                        station.position_long = long
                                        station.banking = banking
                                        station.bonus = bonus
                                        station.status = status
                                        station.bike_stands = bikeStands
                                        station.available_bike_stands = availableBikeStands
                                        station.available_bikes = availableBikes
                                        station.last_update = lastUpdate
                                        station.contract = self.contract
                                        try moc.save()
                                        
                                    } catch let err as NSError {
                                        print("Error: \(err.description)")
                                    }
                                }
                            })
                        }
                    }
                    
                } catch let error as NSError {
                    print("Error: \(error.description)")
                }
                
            })
            task.resume()
            
        } else {
            return
        }
    }
}












