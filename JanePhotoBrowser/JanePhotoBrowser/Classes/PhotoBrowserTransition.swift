//
//  PhotoBrowserTransition.swift
//  JanePhotoBrowser
//
//  Copyright © 2016 Jane. All rights reserved.
//

import UIKit

class PhotoBrowserTransition: NSObject, UIViewControllerAnimatedTransitioning {
    var animateIn:Bool = true
    weak var originView: UIView?
    weak var destinationView: UIView?
    var image: UIImage?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let destinationViewController:UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let image = self.image,
            let originView = self.originView,
            let destinationView = destinationView else {
                transitionContext.completeTransition(true)
                return
        }
        
        let containerView:UIView = transitionContext.containerView
        
        //Create Image View to Animate
        let snapShot = UIImageView()
        snapShot.image = image
        snapShot.contentMode = .scaleAspectFit
        snapShot.frame = originView.convert(originView.bounds, to: nil)
        
        originView.alpha = 0
        
        //Prep destination view controller for animation
        destinationViewController.view.frame = transitionContext.finalFrame(for: destinationViewController)
        destinationViewController.view.alpha = 0
        
        //Prep animating container view
        containerView.addSubview(destinationViewController.view)
        containerView.addSubview(snapShot)
        
        //Animate the transition between view controllers
        UIView.animate(withDuration: 0.4, animations: {
            destinationViewController.view.alpha = 1.0
            snapShot.frame = destinationView.convert(destinationView.bounds, to: nil)
        }) { (finished) in
            snapShot.removeFromSuperview()
            originView.alpha = 1
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
