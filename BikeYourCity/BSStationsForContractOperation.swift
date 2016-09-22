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


class BSStationsForContractOperation: Operation {
    
    let contract: String
    
    init(contract:String) {
        
        self.contract = contract
        super.init()
    }
    
    override func main() {
        
        let urlPath = Constants.kURLServer + Constants.kServiceStations
        let urlPathWithParams = urlPath + "?apiKey=\(Constants.kAPIKey)" + "&contract=\(contract)"
        let url = URL(string: urlPathWithParams)
        
       
        
        if let requestURL = url {
            
            var request = URLRequest(url: requestURL)
            let authString = "\(Constants.kUserName):\(Constants.kPassword)"
            let authData = authString.data(using: String.Encoding.utf8)
            let base64AuthString = authData?.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
            let authValue = "Basic \(base64AuthString)"
            request.addValue(authValue, forHTTPHeaderField: "Authorization")
            request.httpMethod = "GET"
            

            
            let task:URLSessionDataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                
              


                if error != nil {
                    print("Error: \(error.debugDescription)")
                    return
                }
                
                do {
                    
                    if let jsonArray = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.mutableContainers) as? [NSDictionary] {
                        
                    for dict in jsonArray {
                        
                        let number = dict["number"] as? NSNumber
                        let name = dict["name"] as? String
                        let address = dict["address"] as? String
                        let position = dict["position"] as? Dictionary<String, Double>
                        let lat = position?["lat"]
                        let long = position?["lng"]
                        let banking = dict["banking"] as? NSNumber
                        let bonus = dict["bonus"] as? NSNumber
                        let status = dict["status"] as? String
                        let bikeStands = dict["bike_stands"] as? NSNumber
                        let availableBikeStands = dict["available_bike_stands"] as? NSNumber
                        let availableBikes = dict["available_bikes"] as? NSNumber
                        let lastUpdate = dict["last_update"] as? NSNumber
                        
                        let moc = BSNetworkManager.manager.privateMOC
                        moc.perform({
                            
                            if let numberAt = number {
                                
                                let fetchStation = NSFetchRequest<BSStation>(entityName: "BSStation")
                                let predicateStation = NSPredicate(format: "number = %ld", numberAt)
                                fetchStation.predicate = predicateStation
                                
                                let fetchContract = NSFetchRequest<BSContract>(entityName: "BSContract")
                                let predicateContract = NSPredicate(format: "name = %@", self.contract)
                                fetchContract.predicate = predicateContract
                                
                                let station: BSStation
                                
                                do {
                                    let resultsStation = try moc.fetch(fetchStation)
                                    
                                    if resultsStation.count > 0 {
                                        station = resultsStation.first!
                                    } else {
                                        station = NSEntityDescription.insertNewObject(forEntityName: "BSStation", into: moc) as! BSStation
                                    }
                                    
                                    station.number = number
                                    station.name = name
                                    station.address = address
                                    station.position_lat = NSNumber(value: lat!)
                                    station.position_long = NSNumber(value: long!)
                                    station.banking = banking
                                    station.bonus = bonus
                                    station.status = status
                                    station.bike_stands = bikeStands
                                    station.available_bike_stands = availableBikeStands
                                    station.available_bikes = availableBikes
                                    station.last_update = lastUpdate
                                    
                                    let resultsContract = try moc.fetch(fetchContract)
                                    
                                    if resultsContract.count > 0 {
                                        let contractObject = resultsContract.first! as BSContract
                                        station.setValue(contractObject, forKey: "contract")
                                    }
                                    try moc.save()
                                    
                                } catch  {
                                    print("Error: \(error)")
                                }
                            }
                        })
                    }

                    }
                } catch  {
                    print("Error: \(error)")
                }
                
            })
            task.resume()
            
        } else {
            return
        }
    }
}












