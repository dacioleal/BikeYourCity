//
//  BSContractInfoOperation.swift
//  BikeSeville
//
//  Created by Dacio Leal Rodriguez on 22/5/16.
//  Copyright © 2016 Dacio Leal Rodriguez. All rights reserved.
//

// This operation gets information of every contract in jcdecaux bike renting service

import UIKit
import CoreData

class BSContractInfoOperation: NSOperation {
    
    
    let contract: String
    
    init(contract:String) {
        self.contract = contract
        super.init()
    }
    
    override func main() {
        
        let urlPath = Constants.kURLServer.stringByAppendingString(Constants.kServiceContracts)
        let urlPathWithParams = urlPath + "?apiKey=\(Constants.kAPIKey)"
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
                
                do {
                    
                    if let jsonArray = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.AllowFragments) as? NSArray {
                        
                        for dict in jsonArray {
                            
                            let name = dict["name"] as? String
                            let commercialName = dict["commercial_name"] as? String
                            let countryCode = dict["country_code"] as? String
                            
                            let moc = BSNetworkManager.manager.privateMOC
                            moc.performBlock({
                                
                                let fetch = NSFetchRequest(entityName: "BSContract")
                                let predicate = NSPredicate(format: "name = %@", name!)
                                fetch.predicate = predicate
                                
                                let contract: BSContract?
                                
                                do {
                                    
                                    let results = try moc.executeFetchRequest(fetch) as? [BSContract]
                                    
                                    if results?.count > 0 {
                                        
                                        contract = results?.first
                                        contract?.commercial_name = commercialName
                                        contract?.country_code = countryCode
                                        
                                    } else {
                                        
                                        contract = NSEntityDescription.insertNewObjectForEntityForName("BSContract", inManagedObjectContext: moc) as? BSContract
                                        contract?.name = name
                                        contract?.commercial_name = commercialName
                                        contract?.country_code = countryCode
                                    }
                                    
                                    try moc.save()
                        
                                } catch let error as NSError {
                                    print("Error: \(error.description)")
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

