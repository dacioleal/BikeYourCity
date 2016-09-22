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
        let path = Bundle.main.path(forResource: "annotation_green_40x49", ofType: "png")
        
        var img = UIImage(contentsOfFile: path!)
        if let pathStr = path {
            
            let image = UIImage(contentsOfFile: pathStr)
            let cgImage = image?.cgImage
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
            case .stationStatusLowAvailability:
                color = ColorConstants.kLowAvailabilityColor
            case .stationStatusMediumAvailability:
                color = ColorConstants.kMediumAvailabilityColor
            case .stationStatusHighAvailability:
                color = ColorConstants.kHighAvailabilityColor
            }
            
            let attributes = [NSFontAttributeName:UIFont(name:"HelveticaNeue", size: 20.0)!, NSForegroundColorAttributeName:color] as [String : Any]
            string.draw(with: CGRect(x: 20.0, y: 20.0, width: 20.0, height: 20.0), options: .usesFontLeading, attributes: attributes, context: nil)
            img = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
        }
        self.init(cgImage: img!.cgImage!)
        
        //self.integerToShow = integer
    }
    
}
