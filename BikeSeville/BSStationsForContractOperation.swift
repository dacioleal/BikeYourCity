//
//  BSStationsForContractOperation.swift
//  BikeSeville
//
//  Created by Dacio Leal Rodriguez on 22/5/16.
//  Copyright © 2016 Dacio Leal Rodriguez. All rights reserved.
//

import UIKit
import CoreData

class BSStationsForContractOperation: NSOperation {
    
    let contract: String
    
    init(contract:String) {
        self.contract = contract
        super.init()
    }
    
    override func main() {
        
        let urlPath = Constants.kURLServer.stringByAppendingString(Constants.kServiceStations)
        let urlPathWithParams = urlPath + "?apiKey=\(Constants.kAPIKey)" + "&contract=\(contract)"
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
                            
                            let number = dict["number"] as? String
                            let contractName = dict["contract_name"] as? String
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
                                
                                let fetch = NSFetchRequest(entityName: "BSStation")
                                let predicate: NSPredicate
                                
                                if let numberAt = number {
                                    
                                    predicate = NSPredicate(format: "number = %@", numberAt)
                                    
                                } else if let nameAt = name {
                                    
                                    predicate = NSPredicate(format: "name = %@", nameAt)
                                }
                                
                                //Continuar aquí
                                
                                
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












