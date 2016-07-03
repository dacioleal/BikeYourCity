//
//  BSAnnotationImage.swift
//  BikeYourCity
//
//  Created by Dacio Leal Rodriguez on 2/7/16.
//  Copyright © 2016 Dacio Leal Rodriguez. All rights reserved.
//

import UIKit

class BSAnnotationImage: UIImage {
    
    var integerToShow = 0
    let availabilityColor = false
    
    convenience init(numberToShow:Int, status:StationStatus) {
        let path = NSBundle.mainBundle().pathForResource("annotation_green_40x49", ofType: "png")
        
        var img = UIImage(contentsOfFile: path!)
        if let pathStr = path {
            
            let image = UIImage(contentsOfFile: pathStr)
            let cgImage = image?.CGImage
//            print("Width: \(CGImageGetWidth(cgImage))")
//            print("Height: \(CGImageGetHeight(cgImage))")
            
            UIGraphicsBeginImageContext((image?.size)!)
//            let context = UIGraphicsGetCurrentContext()
//            CGContextSetTextDrawingMode(context, .Fill)
//            CGContextSetRGBFillColor(context, 0.5, 0.5, 0.5, 1.0)
            let string = String(format: "%ld", numberToShow)
//            CGContextSetFont(context, CGFontCreateWithFontName("HelveticaNeue"))
//            CGContextSetFontSize(context, 11.0)
            var color : UIColor
            
            switch status {
            case .StationStatusLowAvailability:
                color = ColorConstants.kLowAvailabilityColor
            case .StationStatusMediumAvailability:
                color = ColorConstants.kMediumAvailabilityColor
            case .StationStatusHighAvailability:
                color = ColorConstants.kHighAvailabilityColor
            }
            
            let attributes = [NSFontAttributeName:UIFont(name:"HelveticaNeue", size: 20.0)!, NSForegroundColorAttributeName:color]
            string.drawWithRect(CGRectMake(20.0, 20.0, 20.0, 20.0), options: .UsesFontLeading, attributes: attributes, context: nil)
            img = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
        }
        self.init(CGImage: img!.CGImage!)
        
        //self.integerToShow = integer
    }
    
}
