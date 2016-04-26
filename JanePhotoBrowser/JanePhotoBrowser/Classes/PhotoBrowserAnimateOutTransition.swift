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
        guard let originViewController:PhotoBrowserViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as? PhotoBrowserViewController,
            let destinationViewController:UIViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey),
            let containerView:UIView = transitionContext.containerView(),
            let image = self.imageView,
            let photoView = self.destinationPhotoView,
            let photoViewImage = photoView.selectedImageView else { return }
        
        let snapShot = UIImageView()
        snapShot.image = image.image
        snapShot.contentMode = .ScaleAspectFit
        snapShot.frame = containerView.convertRect(image.frame, toView: nil)
        image.hidden = true
        
        destinationViewController.view.frame = transitionContext.finalFrameForViewController(destinationViewController)
        destinationViewController.view.alpha = 0
        photoViewImage.hidden = true
        
        containerView.addSubview(destinationViewController.view)
        containerView.addSubview(snapShot)
        
        let selectedIndex:Int = originViewController.photoView?.selectedIndex?.row ?? 0
        photoView.scrollToPhoto(atIndex: selectedIndex, animated: false)
        
        UIView.animateWithDuration(0.4, animations: {
            destinationViewController.view.alpha = 1.0
            if let frame = photoView.superview?.convertRect(photoView.frame, toView: containerView) {
                snapShot.frame = frame
            }
        }) { (finished) in
            photoViewImage.hidden = false
            image.hidden = false
            snapShot.removeFromSuperview()
            
            transitionContext.completeTransition(true)
        }
    }
}