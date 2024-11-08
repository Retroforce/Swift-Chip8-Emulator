//
//  BitBlitter.swift
//  Chip8
//
//  Created by Wilbur on 2016/02/24.
//  Copyright © 2016 Retroforce. All rights reserved.
//

import Foundation
import UIKit

class BitBlitter {

    static func blitScreenBuffer(canvasWidth width:CGFloat, canvasHeight height:CGFloat, screenBuffer:[UInt8]) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        let width = width/63
        let height = height/31
        
        var xx = 0
        var yy = 0
        var bufferIndex = 0
        for y in 0..<32 {
            for x in 0..<64 {
                
                let rectangle = CGRectMake(CGFloat(xx), CGFloat(yy), width, height)
                
                CGContextSetFillColorWithColor(context, (Int(screenBuffer[bufferIndex]) == 0) ? UIColor.blackColor().CGColor:UIColor.whiteColor().CGColor)
                CGContextSetStrokeColorWithColor(context, UIColor.greenColor().CGColor)
                CGContextSetLineWidth(context, 0)
                
                CGContextAddRect(context, rectangle)
                CGContextDrawPath(context, .Fill)
                
                xx += Int(width)
                
                bufferIndex += 1
            }
            
            xx = 0
            yy += Int(height)
        }
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return img
    }
}
