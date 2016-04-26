//
//  PhotoBrowserTransition.swift
//  JanePhotoBrowser
//
//  Copyright © 2016 Jane. All rights reserved.
//

import UIKit

class PhotoBrowserAnimateOutTransition: NSObject, UIViewControllerAnimatedTransitioning {
    var imageView:UIImageView?
    var destinationPhotoView:PhotoBrowserView?
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.4
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let destinationViewController:UIViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey),
            let containerView:UIView = transitionContext.containerView(),
            let image = self.imageView,
            let photoView = self.destinationPhotoView?.selectedImageView else { return }
        
        let snapShot = UIImageView()
        snapShot.image = image.image
        snapShot.contentMode = .ScaleAspectFit
        snapShot.frame = containerView.convertRect(image.frame, toView: nil)
        image.hidden = true
        
        destinationViewController.view.frame = transitionContext.finalFrameForViewController(destinationViewController)
        destinationViewController.view.alpha = 0
        photoView.hidden = true
        
        containerView.addSubview(destinationViewController.view)
        containerView.addSubview(snapShot)
        
        UIView.animateWithDuration(0.4, animations: {
            destinationViewController.view.alpha = 1.0
            if let frame = photoView.superview?.convertRect(photoView.frame, toView: containerView) {
                snapShot.frame = frame
            }
        }) { (finished) in
            photoView.hidden = false
            image.hidden = false
            snapShot.removeFromSuperview()
            
            transitionContext.completeTransition(true)
        }
    }
}