//
//  PhotoBrowserViewController.swift
//  JanePhotoBrowser
//
//  Copyright © 2016 Jane. All rights reserved.
//

import UIKit

public class PhotoBrowserViewController: UIViewController {
    //MARK: - Private Variables
    private var interactiveAnimation: UIPercentDrivenInteractiveTransition?
    
    //MARK: - Variables
    var initialIndexPath : NSIndexPath?
    weak var originPhotoView: PhotoBrowserView?
    public var photoView:PhotoBrowserView? = PhotoBrowserView()
    
    //MARK: - UIViewController
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        guard let photoView = self.photoView else { return }
        self.view.addSubview(photoView)
        
        photoView.canZoom = true
        photoView.translatesAutoresizingMaskIntoConstraints = false
        photoView.delegate = self
        photoView.shouldDisplayCloseButton = true
        
        //Setup Layout for PhotoView
        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: [], metrics: nil, views: ["view":photoView])
        let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: [], metrics: nil, views: ["view":photoView])
        self.view.addConstraints(vConstraints)
        self.view.addConstraints(hConstraints)
        
        //Add pan gesture to watch for sliding up to dismiss image
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.panGesture(_:)))
        photoView.addGestureRecognizer(pan)
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        guard let indexPath = self.initialIndexPath, let photoView = self.photoView else { return }
        photoView.scrollToPhoto(atIndex: indexPath.item, animated: false)
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let photoView = self.photoView else { return }
        if photoView.viewIsAnimating {
            photoView.visibleImageView()?.hidden = true
        }
    }
    
    func panGesture(recognizer:UIPanGestureRecognizer) {
        let flickSpeed:CGFloat = -1300
        
        //Find progress of upward swipe.
        var progress = recognizer.translationInView(self.view).y / self.view.bounds.size.height
        progress = fabs(max(-1.0, min(0.0, progress * 2)))

        //Update progress
        switch (recognizer.state) {
            case .Began:
                self.interactiveAnimation = UIPercentDrivenInteractiveTransition()
                self.dismissViewControllerAnimated(true, completion: nil)
            case .Changed:
                self.interactiveAnimation?.updateInteractiveTransition(progress)
            case .Ended: fallthrough
            case .Cancelled:
                //If we have swiped over half way, or we flicked the view upward then we want to finish the transition
                if progress > 0.5 || recognizer.velocityInView(self.view).y < flickSpeed {
                    self.interactiveAnimation?.finishInteractiveTransition()
                } else {
                    self.interactiveAnimation?.cancelInteractiveTransition()
                }
                
                self.interactiveAnimation = nil
            default: break
        }
    }
}

//MARK: - PhotoBrowserDelegate
extension PhotoBrowserViewController:PhotoBrowserDelegate {
    public func photoBrowser(photoBrowser: PhotoBrowserView, photoTappedAtIndex indexPath: NSIndexPath) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        self.interactiveAnimation?.finishInteractiveTransition()
    }
}

//MARK: - UIViewControllerTransistioningDelegate
extension PhotoBrowserViewController:UIViewControllerTransitioningDelegate {
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let originImageView = self.originPhotoView?.visibleImageView() else { return nil }
        let transition = PhotoBrowserTransition()
        transition.imageView = originImageView
        transition.destinationPhotoView = self.photoView
        
        return transition
    }
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let photoImageViewController = dismissed as? PhotoBrowserViewController,
            let originPhotoView = self.originPhotoView else { return nil }
        
        let transition = PhotoBrowserTransition()
        transition.animateIn = false
        transition.imageView = photoImageViewController.photoView?.visibleImageView()
        transition.destinationPhotoView = originPhotoView
        transition.originPhotoView = photoImageViewController.photoView
        
        return transition
    }
    
    public func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let _ = animator as? PhotoBrowserTransition else { return nil }
        return self.interactiveAnimation
    }
}
