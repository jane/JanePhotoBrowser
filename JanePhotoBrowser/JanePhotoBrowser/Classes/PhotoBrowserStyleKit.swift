//
//  PhotoBrowserStyleKit.swift
//  JanePhotoBrowser
//
//  Created by Gordon Tucker on 6/2/16.
//  Copyright © 2016 Jane. All rights reserved.
//

import UIKit

public class PhotoBrowserStyleKit: NSObject {
    
    public class func drawXIcon(fillColor fillColor: UIColor = UIColor(red: 0.824, green: 0.334, blue: 0.746, alpha: 1.000)) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()
        
        //// Bezier Drawing
        CGContextSaveGState(context!)
        CGContextTranslateCTM(context!, 59, 54.22)
        
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPoint(x: -46.01, y: -42.23))
        bezierPath.addLineToPoint(CGPoint(x: -40.05, y: -48.28))
        bezierPath.addCurveToPoint(CGPoint(x: -40.05, y: -48.54), controlPoint1: CGPoint(x: -39.98, y: -48.35), controlPoint2: CGPoint(x: -39.98, y: -48.47))
        bezierPath.addLineToPoint(CGPoint(x: -40.67, y: -49.17))
        bezierPath.addCurveToPoint(CGPoint(x: -40.93, y: -49.17), controlPoint1: CGPoint(x: -40.75, y: -49.24), controlPoint2: CGPoint(x: -40.86, y: -49.24))
        bezierPath.addLineToPoint(CGPoint(x: -46.89, y: -43.12))
        bezierPath.addLineToPoint(CGPoint(x: -52.84, y: -49.16))
        bezierPath.addCurveToPoint(CGPoint(x: -53.1, y: -49.16), controlPoint1: CGPoint(x: -52.91, y: -49.23), controlPoint2: CGPoint(x: -53.03, y: -49.23))
        bezierPath.addLineToPoint(CGPoint(x: -53.72, y: -48.53))
        bezierPath.addCurveToPoint(CGPoint(x: -53.72, y: -48.27), controlPoint1: CGPoint(x: -53.79, y: -48.46), controlPoint2: CGPoint(x: -53.79, y: -48.34))
        bezierPath.addLineToPoint(CGPoint(x: -47.76, y: -42.22))
        bezierPath.addLineToPoint(CGPoint(x: -53.72, y: -36.17))
        bezierPath.addCurveToPoint(CGPoint(x: -53.72, y: -35.91), controlPoint1: CGPoint(x: -53.79, y: -36.1), controlPoint2: CGPoint(x: -53.79, y: -35.98))
        bezierPath.addLineToPoint(CGPoint(x: -53.1, y: -35.28))
        bezierPath.addCurveToPoint(CGPoint(x: -52.84, y: -35.28), controlPoint1: CGPoint(x: -53.03, y: -35.21), controlPoint2: CGPoint(x: -52.91, y: -35.21))
        bezierPath.addLineToPoint(CGPoint(x: -46.89, y: -41.33))
        bezierPath.addLineToPoint(CGPoint(x: -40.93, y: -35.28))
        bezierPath.addCurveToPoint(CGPoint(x: -40.67, y: -35.28), controlPoint1: CGPoint(x: -40.86, y: -35.21), controlPoint2: CGPoint(x: -40.75, y: -35.21))
        bezierPath.addLineToPoint(CGPoint(x: -40.05, y: -35.91))
        bezierPath.addCurveToPoint(CGPoint(x: -40.05, y: -36.17), controlPoint1: CGPoint(x: -39.98, y: -35.98), controlPoint2: CGPoint(x: -39.98, y: -36.1))
        bezierPath.addLineToPoint(CGPoint(x: -46.01, y: -42.23))
        bezierPath.closePath()
        bezierPath.miterLimit = 4;
        
        fillColor.setFill()
        bezierPath.fill()
        
        CGContextRestoreGState(context!)
    }
    
    public class func imageOfXIcon(fillColor fillColor: UIColor = UIColor(red: 0.824, green: 0.334, blue: 0.746, alpha: 1.000)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 24, height: 24), false, 0)
        PhotoBrowserStyleKit.drawXIcon(fillColor: fillColor)
        
        let imageOfXIcon = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return imageOfXIcon!
    }

}
