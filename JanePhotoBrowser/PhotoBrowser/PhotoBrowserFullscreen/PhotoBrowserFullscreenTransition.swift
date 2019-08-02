//
//  PhotoBrowserFullscreenTransition.swift
//  PhotoBrowser
//
//  Created by Gordon Tucker on 8/1/19.
//  Copyright © 2019 Jane. All rights reserved.
//

import UIKit

public class PhotoBrowserFullscreenTransition: NSObject, UIViewControllerAnimatedTransitioning {
    var animateIn: Bool = true
    var originImageView: UIImageView?
    var destinationImageView: UIImageView?
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let destinationViewController:UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let originImageView = self.originImageView,
            let destiniationImageView = self.destinationImageView else {
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                return
        }
        
        let containerView: UIView = transitionContext.containerView
        
        //Create Image View to Animate
        let snapShot = UIImageView()
        snapShot.image = originImageView.image
        snapShot.contentMode = .scaleAspectFit
        if let frame = originImageView.superview?.convert(originImageView.frame, to: containerView) {
            snapShot.frame = frame
        }
        
        originImageView.alpha = 0
        
        //Prep destination view controller for animation
        destinationViewController.view.frame = transitionContext.finalFrame(for: destinationViewController)
        destinationViewController.view.alpha = 0
        
        //Hide the distination photoview until the animation is finished
        destiniationImageView.alpha = 0
        
        //Prep animating container view
        containerView.addSubview(destinationViewController.view)
        containerView.addSubview(snapShot)
        
        //Animate the transition between view controllers
        UIView.animate(withDuration: 0.4, animations: {
            destinationViewController.view.alpha = 1.0
            if let frame = destiniationImageView.superview?.convert(destiniationImageView.frame, to: containerView), !self.animateIn {
                // Old height adjustment:  - (photoView.showPreview == true ? (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0) + 42 : -8)
                let newFrame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height)
                snapShot.frame = newFrame
            } else {
                // Old height adjustment:  - (photoView.showPreview == true ? (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0) + 42 : -8)
                let destinationFrame = destinationViewController.view.frame
                let newFrame = CGRect(x: destinationFrame.minX, y: destinationFrame.minY, width: destinationFrame.width, height: destinationFrame.height)
                snapShot.frame = newFrame
            }
        }) { _ in
            destiniationImageView.superview?.bringSubviewToFront(destiniationImageView)
            UIView.animate(withDuration: 0.3, animations: {
                destiniationImageView.alpha = 1
                originImageView.alpha = 1
            }, completion: { _ in
                snapShot.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
    }
}
