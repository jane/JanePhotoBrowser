//
//  PhotoBrowserViewController.swift
//  JanePhotoBrowser
//
//  Copyright © 2016 Jane. All rights reserved.
//

import UIKit

class PhotoBrowserViewController: UIViewController {
    private var interactiveAnimation: UIPercentDrivenInteractiveTransition?
    var initialIndexPath : NSIndexPath?
    weak var originPhotoView: PhotoBrowserView?
    var photoView:PhotoBrowserView? = PhotoBrowserView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let photoView = self.photoView else { return }
        self.view.addSubview(photoView)
        
        photoView.canZoom = true
        photoView.translatesAutoresizingMaskIntoConstraints = false
        
        self.photoView?.delegate = self
        
        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: [], metrics: nil, views: ["view":photoView])
        let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: [], metrics: nil, views: ["view":photoView])
        self.view.addConstraints(vConstraints)
        self.view.addConstraints(hConstraints)
        
        //Add pan gesture to watch for sliding up to dismiss image
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.panGesture(_:)))
        photoView.addGestureRecognizer(pan)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let indexPath = self.initialIndexPath,
            let photoView = self.photoView else { return }
        photoView.scrollToPhoto(atIndex: indexPath.item, animated: false)
    }
    
    func panGesture(recognizer:UIPanGestureRecognizer) {
        var progress = recognizer.translationInView(self.view).y / self.view.bounds.size.height
        progress = fabs(max(-1.0, min(0.0, progress * 2)))

        switch (recognizer.state) {
            case .Began:
                self.interactiveAnimation = UIPercentDrivenInteractiveTransition()
                self.dismissViewControllerAnimated(true, completion: nil)
            case .Changed:
                self.interactiveAnimation?.updateInteractiveTransition(progress)
            case .Ended: fallthrough
            case .Cancelled:
                if progress > 0.5 || recognizer.velocityInView(self.view).y < -1500 {
                    self.interactiveAnimation?.finishInteractiveTransition()
                } else {
                    self.interactiveAnimation?.cancelInteractiveTransition()
                }
                
                self.interactiveAnimation = nil
            default: break
        }
    }
}

extension PhotoBrowserViewController:PhotoBrowserDelegate {
    func photoBrowser(photoBrowser: PhotoBrowserView, photoTappedAtIndex indexPath: NSIndexPath) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        self.interactiveAnimation?.finishInteractiveTransition()
    }
}

extension PhotoBrowserViewController:UIViewControllerTransitioningDelegate {
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let originImageView = self.originPhotoView?.selectedImageView else { return nil }
        let transition = PhotoBrowserAnimateInTransition()
        transition.imageView = originImageView
        
        return transition
    }
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let photoImageViewController = dismissed as? PhotoBrowserViewController,
            let originPhotoView = self.originPhotoView else { return nil }
        
        let transition = PhotoBrowserAnimateOutTransition()
        
        transition.imageView = photoImageViewController.photoView?.visibleImageView()
        transition.destinationPhotoView = originPhotoView
        
        return transition
    }
    
    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let _ = animator as? PhotoBrowserAnimateOutTransition else { return nil }
        return self.interactiveAnimation
    }
}
