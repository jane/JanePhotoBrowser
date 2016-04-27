//
//  PhotoBrowserTransition.swift
//  JanePhotoBrowser
//
//  Copyright © 2016 Jane. All rights reserved.
//

import UIKit

class PhotoBrowserTransition: NSObject, UIViewControllerAnimatedTransitioning {
    var animateIn:Bool = true
    var imageView:UIImageView?
    var originPhotoView:PhotoBrowserView?
    var destinationPhotoView:PhotoBrowserView?
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.4
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let destinationViewController:UIViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey),
            let containerView:UIView = transitionContext.containerView(),
            let image = self.imageView,
            let photoView = self.destinationPhotoView else { return }
        
        //Create Image View to Animate
        let snapShot = UIImageView()
        snapShot.image = image.image
        snapShot.contentMode = .ScaleAspectFit
        if let frame = image.superview?.convertRect(image.frame, toView: containerView) {
            snapShot.frame = frame
        }
        
        //Hide UIImageView that we are animating from
        image.hidden = true
        
        //Prep destination view controller for animation
        destinationViewController.view.frame = transitionContext.finalFrameForViewController(destinationViewController)
        destinationViewController.view.alpha = 0
        
        //Hide the distination photoview until the animation is finished
        photoView.visibleImageView()?.hidden = true
        photoView.viewIsAnimating = true
        
        //Prep animating container view
        containerView.addSubview(destinationViewController.view)
        containerView.addSubview(snapShot)
        
        if let selectedIndex:Int = originPhotoView?.visibleIndexPath()?.row {
            photoView.scrollToPhoto(atIndex: selectedIndex, animated: false)
        }
        
        //Animate the transition between view controllers
        UIView.animateWithDuration(0.4, animations: {
            destinationViewController.view.alpha = 1.0
            if let frame = photoView.superview?.convertRect(photoView.frame, toView: containerView) where !self.animateIn {
                snapShot.frame = frame
            } else {
                snapShot.frame = destinationViewController.view.frame
            }
        }) { (finished) in
            photoView.visibleImageView()?.hidden = false
            photoView.viewIsAnimating = false
            image.hidden = false
            snapShot.removeFromSuperview()
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
}