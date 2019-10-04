//
//  PhotoBrowserStyleKit.swift
//  JanePhotoBrowser
//
//  Created by Gordon Tucker on 6/2/16.
//  Copyright © 2016 Jane. All rights reserved.
//

import UIKit

public class PhotoBrowserIconography: NSObject {

    public static func drawXIcon(fillColor: UIColor = UIColor(red: 0.07, green: 0.07, blue: 0.07, alpha: 1.000)) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()
        
        //// Bezier Drawing
        context?.saveGState()
        context?.translateBy(x: 59, y: 54.22)
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: -46.01, y: -42.23))
        bezierPath.addLine(to: CGPoint(x: -40.05, y: -48.28))
        bezierPath.addCurve(to: CGPoint(x: -40.05, y: -48.54), controlPoint1: CGPoint(x: -39.98, y: -48.35), controlPoint2: CGPoint(x: -39.98, y: -48.47))
        bezierPath.addLine(to: CGPoint(x: -40.67, y: -49.17))
        bezierPath.addCurve(to: CGPoint(x: -40.93, y: -49.17), controlPoint1: CGPoint(x: -40.75, y: -49.24), controlPoint2: CGPoint(x: -40.86, y: -49.24))
        bezierPath.addLine(to: CGPoint(x: -46.89, y: -43.12))
        bezierPath.addLine(to: CGPoint(x: -52.84, y: -49.16))
        bezierPath.addCurve(to: CGPoint(x: -53.1, y: -49.16), controlPoint1: CGPoint(x: -52.91, y: -49.23), controlPoint2: CGPoint(x: -53.03, y: -49.23))
        bezierPath.addLine(to: CGPoint(x: -53.72, y: -48.53))
        bezierPath.addCurve(to: CGPoint(x: -53.72, y: -48.27), controlPoint1: CGPoint(x: -53.79, y: -48.46), controlPoint2: CGPoint(x: -53.79, y: -48.34))
        bezierPath.addLine(to: CGPoint(x: -47.76, y: -42.22))
        bezierPath.addLine(to: CGPoint(x: -53.72, y: -36.17))
        bezierPath.addCurve(to: CGPoint(x: -53.72, y: -35.91), controlPoint1: CGPoint(x: -53.79, y: -36.1), controlPoint2: CGPoint(x: -53.79, y: -35.98))
        bezierPath.addLine(to: CGPoint(x: -53.1, y: -35.28))
        bezierPath.addCurve(to: CGPoint(x: -52.84, y: -35.28), controlPoint1: CGPoint(x: -53.03, y: -35.21), controlPoint2: CGPoint(x: -52.91, y: -35.21))
        bezierPath.addLine(to: CGPoint(x: -46.89, y: -41.33))
        bezierPath.addLine(to: CGPoint(x: -40.93, y: -35.28))
        bezierPath.addCurve(to: CGPoint(x: -40.67, y: -35.28), controlPoint1: CGPoint(x: -40.86, y: -35.21), controlPoint2: CGPoint(x: -40.75, y: -35.21))
        bezierPath.addLine(to: CGPoint(x: -40.05, y: -35.91))
        bezierPath.addCurve(to: CGPoint(x: -40.05, y: -36.17), controlPoint1: CGPoint(x: -39.98, y: -35.98), controlPoint2: CGPoint(x: -39.98, y: -36.1))
        bezierPath.addLine(to: CGPoint(x: -46.01, y: -42.23))
        bezierPath.close()
        bezierPath.miterLimit = 4;
        
        fillColor.setFill()
        bezierPath.fill()
        
        context?.restoreGState()
    }
    
    public static func imageOfXIcon(fillColor: UIColor = UIColor(red: 0.07, green: 0.07, blue: 0.07, alpha: 1.000)) -> UIImage {
        if #available(iOS 13, *),
            let image = UIImage(systemName: "xmark") {
            return image
        }
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 24, height: 24), false, 0)
        PhotoBrowserIconography.drawXIcon(fillColor: fillColor)
        
        let imageOfXIcon = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return imageOfXIcon!
    }
    
    public static func imageOfZoomInIcon() -> UIImage? {
        if #available(iOS 13, *) {
            return UIImage(systemName: "arrow.up.left.and.arrow.down.right")
        }
        return UIImage(named: "photobrowser-zoom-in") ?? UIImage(named: "zoom-in", in: Bundle(for: PhotoBrowserIconography.self), compatibleWith: nil)
    }
    
    public static func imageOfZoomOutIcon() -> UIImage? {
        if #available(iOS 13, *) {
            return UIImage(systemName: "arrow.down.right.and.arrow.up.left")
        }
        return UIImage(named: "photobrowser-zoom-out") ?? UIImage(named: "zoom-out", in: Bundle(for: PhotoBrowserIconography.self), compatibleWith: nil)
    }
}
