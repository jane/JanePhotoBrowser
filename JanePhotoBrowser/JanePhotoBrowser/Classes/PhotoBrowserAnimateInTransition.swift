//
//  PhotoBrowserTransition.swift
//  JanePhotoBrowser
//
//  Copyright © 2016 Jane. All rights reserved.
//

import UIKit

class PhotoBrowserAnimateInTransition: NSObject, UIViewControllerAnimatedTransitioning {
    var imageView:UIImageView?
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.4
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let destinationViewController:PhotoBrowserViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as? PhotoBrowserViewController,
            let containerView:UIView = transitionContext.containerView(),
            let image = self.imageView,
            let photoView = destinationViewController.photoView else { return }
        
        let snapShot = UIImageView()
        snapShot.image = image.image
        snapShot.contentMode = .ScaleAspectFit
        
        if let frame = image.superview?.convertRect(image.frame, toView: containerView) {
            snapShot.frame = frame
        }
        
        image.hidden = true
        
        destinationViewController.view.frame = transitionContext.finalFrameForViewController(destinationViewController)
        destinationViewController.view.alpha = 0
        photoView.hidden = true
        
        containerView.addSubview(destinationViewController.view)
        containerView.addSubview(snapShot)
        
        UIView.animateWithDuration(0.4, animations: {
            destinationViewController.view.alpha = 1.0
            let newFrame = destinationViewController.view.frame
            snapShot.frame = newFrame
        }) { (finished) in
            photoView.hidden = false
            image.hidden = false
            snapShot.removeFromSuperview()
            
            transitionContext.completeTransition(true)
        }
    }
}
