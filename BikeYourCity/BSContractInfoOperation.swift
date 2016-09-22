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


class BSContractInfoOperation: Operation {
    
    
    let contract: String
    
    init(contract:String) {
        self.contract = contract
        super.init()
    }
    
    override func main() {
        
        let urlPath = Constants.kURLServer + Constants.kServiceContracts
        let urlPathWithParams = urlPath + "?apiKey=\(Constants.kAPIKey)"
        let url = URL(string: urlPathWithParams)
        
        
        if let requestURL = url {
            
            var request = URLRequest(url: requestURL)
            let authString = "\(Constants.kUserName):\(Constants.kPassword)"
            let authData = authString.data(using: String.Encoding.utf8)
            let base64AuthString = authData?.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
            let authValue = "Basic \(base64AuthString)"
            request.addValue(authValue, forHTTPHeaderField: "Authorization")
            request.httpMethod = "GET"
            

            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                
                if error != nil {
                    print("Error: \(error.debugDescription)")
                    return
                }
                
                do {
                    
                    if let jsonArray = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments) as? [NSDictionary] {
                        
                        for dict in jsonArray {
                            
                            let name = dict["name"] as? String
                            let commercialName = dict["commercial_name"] as? String
                            let countryCode = dict["country_code"] as? String
                            
                            let moc = BSNetworkManager.manager.privateMOC
                            moc.perform({
                                
                                let fetch = NSFetchRequest<BSContract>(entityName: "BSContract")
                                let predicate = NSPredicate(format: "name = %@", name!)
                                fetch.predicate = predicate
                                
                                let contract: BSContract?
                                
                                do {
                                    
                                    let results = try moc.fetch(fetch)
                                    
                                    if results.count > 0 {
                                        
                                        contract = results.first
                                        contract?.commercial_name = commercialName
                                        contract?.country_code = countryCode
                                        
                                    } else {
                                        
                                        contract = NSEntityDescription.insertNewObject(forEntityName: "BSContract", into: moc) as? BSContract
                                        contract?.name = name
                                        contract?.commercial_name = commercialName
                                        contract?.country_code = countryCode
                                    }
                                    
                                    try moc.save()
                        
                                } catch {
                                    print("Error: \(error)")
                                }
                            })
                        }
                    }
                } catch {
                    print("Error: \(error)")
                }
            })
            task.resume()
            
        } else {
             return
        }
    }
}

