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
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let destinationViewController:UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let image = self.imageView,
            let photoView = self.destinationPhotoView else {
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                return
        }
        
        let containerView: UIView = transitionContext.containerView
        
        //Create Image View to Animate
        let snapShot = UIImageView()
        snapShot.image = image.image
        snapShot.contentMode = .scaleAspectFit
        if let frame = image.superview?.convert(image.frame, to: containerView) {
            snapShot.frame = frame
        }
        
        image.alpha = 0
        
        //Prep destination view controller for animation
        destinationViewController.view.frame = transitionContext.finalFrame(for: destinationViewController)
        destinationViewController.view.alpha = 0
        
        //Hide the distination photoview until the animation is finished
        photoView.alpha = 0
        
        //Prep animating container view
        containerView.addSubview(destinationViewController.view)
        containerView.addSubview(snapShot)
        
        //Animate the transition between view controllers
        UIView.animate(withDuration: 0.4, animations: {
            destinationViewController.view.alpha = 1.0
            if let frame = photoView.superview?.convert(photoView.frame, to: containerView), !self.animateIn {
                let newFrame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height - (photoView.showPreview == true ? (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0) + 42 : -8))
                snapShot.frame = newFrame
            } else {
                let destinationFrame = destinationViewController.view.frame
                let newFrame = CGRect(x: destinationFrame.minX, y: destinationFrame.minY, width: destinationFrame.width, height: destinationFrame.height - (photoView.showPreview == true ? (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0) + 42 : -8))
                snapShot.frame = newFrame
            }
        }) { _ in
            photoView.superview?.bringSubviewToFront(photoView)
            UIView.animate(withDuration: 0.3, animations: {
                photoView.alpha = 1
                image.alpha = 1
            }, completion: { _ in
                snapShot.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
    }
}
