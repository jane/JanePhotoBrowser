//
//  PhotoBrowserFullscreenTransition.swift
//  PhotoBrowser
//
//  Created by Gordon Tucker on 8/1/19.
//  Copyright © 2019 Jane. All rights reserved.
//

import UIKit

public class PhotoBrowserFullscreenTransition: NSObject, UIViewControllerAnimatedTransitioning {
    fileprivate let transitionDuration: TimeInterval = 0.4
    
    public var animateIn: Bool = true
    public var sourceView: UIImageView?
    public var destinationView: UIView?
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.transitionDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let destinationViewController:UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let sourceViewController: UIViewController = transitionContext.viewController(forKey: .from),
            let sourceView = self.sourceView,
            let destinationView = self.destinationView else { transitionContext.completeTransition(false); return }
        
        let containerView: UIView = transitionContext.containerView
        
        let snapshot: UIImageView = UIImageView()
        
        snapshot.image = sourceView.image
        snapshot.backgroundColor = UIColor.clear
        snapshot.contentMode = .scaleAspectFit
        
        if let frame = sourceView.superview?.convert(sourceView.frame, to: containerView) {
            snapshot.frame = frame
        }
        
        sourceView.isHidden = true
        
        destinationViewController.view.frame = transitionContext.finalFrame(for: destinationViewController)
        destinationViewController.view.alpha = 0
        
        containerView.addSubview(destinationViewController.view)
        containerView.addSubview(snapshot)
        
        destinationViewController.view.layoutIfNeeded()
        
        destinationView.alpha = 0.0
        
        sourceViewController.view.alpha = 0.0
        
        UIView.animate(withDuration: 0.2, delay: 0.3, options: [.curveEaseIn], animations: {
            destinationViewController.view.alpha = 1.0
        }, completion: { _ in
            destinationView.alpha = 1.0
            sourceViewController.view.alpha = 1.0
            sourceView.isHidden = false
            snapshot.removeFromSuperview()
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
        
        UIView.animate(withDuration: 0.35, delay: 0, options: [.curveEaseOut], animations: {
            if let frame = destinationView.superview?.convert(destinationView.frame, to: containerView) {
                snapshot.frame = frame
            } else {
                snapshot.frame = destinationViewController.view.frame
            }
        })
    }
}
