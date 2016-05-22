//
//  BSStationsForContractOperation.swift
//  BikeSeville
//
//  Created by Dacio Leal Rodriguez on 22/5/16.
//  Copyright © 2016 Dacio Leal Rodriguez. All rights reserved.
//

import UIKit

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
                
                let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("ResponseString: \(responseString)")
                
                do {
                    
                    if let jsonDict = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.AllowFragments) as? NSDictionary {
                        
                        
                        
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
