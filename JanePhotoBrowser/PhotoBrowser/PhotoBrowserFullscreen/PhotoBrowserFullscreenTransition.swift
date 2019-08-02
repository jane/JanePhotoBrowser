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
    
    var originNumberView: ImageNumberView?
    var destinationNumberView: ImageNumberView?
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let destinationViewController:UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let originImageView = self.originImageView,
            let destinationImageView = self.destinationImageView else {
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                return
        }
        
        let containerView: UIView = transitionContext.containerView
        
        //Prep destination view controller for animation
        destinationViewController.view.frame = transitionContext.finalFrame(for: destinationViewController)
        destinationViewController.view.alpha = 0
        containerView.addSubview(destinationViewController.view)
        
        //Create Image View to Animate
        let imageSnapshotView = UIImageView()
        imageSnapshotView.image = originImageView.image
        imageSnapshotView.contentMode = .scaleAspectFit
        if let frame = originImageView.superview?.convert(originImageView.frame, to: containerView) {
            imageSnapshotView.frame = frame
        }
        
        self.animateViewTransition(originView: originImageView, destinationView: destinationImageView, snapshotView: imageSnapshotView, using: transitionContext, complete: {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
        
        if let originNumberView = self.originNumberView, let destinationNumberView = self.destinationNumberView {
            let numberSnapshotView = ImageNumberView()
            
            if let frame = originNumberView.superview?.convert(originNumberView.frame, to: containerView) {
                numberSnapshotView.frame = frame
            }
            
            numberSnapshotView.font = originNumberView.font
            numberSnapshotView.text = originNumberView.text
            
            self.animateViewTransition(originView: originNumberView, destinationView: destinationNumberView, snapshotView: numberSnapshotView, using: transitionContext, calculateFrame: {
                
                if let frame = destinationNumberView.superview?.convert(destinationNumberView.frame, to: containerView), !self.animateIn {
                    let diff = originNumberView.frame.width - frame.width
                    // the destination is off slightly, adjust our frame to fit right
                    if diff != 0 {
                        return CGRect(x: frame.minX - diff, y: frame.minY, width: frame.width + diff, height: frame.height)
                    }
                    
                    return frame
                } else {
                    let destFrame = destinationViewController.view.frame
                    let x = destFrame.width - numberSnapshotView.frame.width - 16
                    let y = destFrame.height - numberSnapshotView.frame.height - 82 - destinationViewController.view.safeAreaInsets.bottom
                    return CGRect(x: x, y: y, width: numberSnapshotView.bounds.width, height:  numberSnapshotView.bounds.height)
                }
            })
        }
    }
    
    public func animateViewTransition(originView: UIView, destinationView: UIView, snapshotView: UIView, using transitionContext: UIViewControllerContextTransitioning, calculateFrame: (() -> CGRect)? = nil, complete: (() -> ())? = nil) {
        guard let destinationViewController:UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else { return }
        
        let containerView: UIView = transitionContext.containerView
        
        originView.alpha = 0
        
        //Hide the distination photoview until the animation is finished
        destinationView.alpha = 0
        
        //Prep animating container view
        containerView.addSubview(snapshotView)
        
        //Animate the transition between view controllers
        UIView.animate(withDuration: 0.4, animations: {
            destinationViewController.view.alpha = 1.0
            if let frame = calculateFrame?() {
                snapshotView.frame = frame
            } else if let frame = destinationView.superview?.convert(destinationView.frame, to: containerView), !self.animateIn {
                let newFrame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height)
                snapshotView.frame = newFrame
            } else {
                snapshotView.frame = destinationViewController.view.frame
            }
        }) { _ in
            UIView.animate(withDuration: 0.1, animations: {
                destinationView.alpha = 1
                originView.alpha = 1
            }, completion: { _ in
                snapshotView.removeFromSuperview()
                complete?()
            })
        }
    }
}
