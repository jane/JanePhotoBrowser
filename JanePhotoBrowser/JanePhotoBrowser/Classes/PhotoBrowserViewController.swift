//
//  PhotoBrowserViewController.swift
//  JanePhotoBrowser
//
//  Copyright © 2016 Jane. All rights reserved.
//

import UIKit

open class PhotoBrowserViewController: UIViewController {
    //MARK: - Private Variables
    fileprivate var interactiveAnimation: UIPercentDrivenInteractiveTransition?
    
    //MARK: - Variables
    open var initialIndexPath : IndexPath?
    weak open var originPhotoView: PhotoBrowserView? {
        didSet {
            // Make sure the label is updated to be the right number and triggers a view event
            if self.originPhotoView?.visibleRow == 1 {
                self.photoView?.visibleRow = -1
            }
            self.photoView?.updateLabelView()
        }
    }
    open var photoView:PhotoBrowserView? = PhotoBrowserView()
    
    //MARK: - UIViewController
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        guard let photoView = self.photoView else { return }
        self.view.addSubview(photoView)
        
        photoView.canZoom = true
        photoView.translatesAutoresizingMaskIntoConstraints = false
        photoView.delegate = self
        photoView.shouldDisplayCloseButton = true
        
        //Setup Layout for PhotoView
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: ["view":photoView])
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: ["view":photoView])
        self.view.addConstraints(vConstraints)
        self.view.addConstraints(hConstraints)
        
        //Add pan gesture to watch for sliding up to dismiss image
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.panGesture(_:)))
        photoView.addGestureRecognizer(pan)
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let indexPath = self.initialIndexPath, let photoView = self.photoView else { return }
        photoView.scrollToPhoto(atIndex: (indexPath as NSIndexPath).item, animated: false)
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let photoView = self.photoView else { return }
        if photoView.viewIsAnimating {
            photoView.visibleImageView()?.isHidden = true
        }
    }
    
    @objc func panGesture(_ recognizer:UIPanGestureRecognizer) {
        let flickSpeed:CGFloat = 1300
        
        //Find progress of upward swipe.
        var progress = recognizer.translation(in: self.view).y / self.view.bounds.size.height
        progress = min(1.0, fabs(progress) * 2)
        
        //Update progress
        switch (recognizer.state) {
            case .began:
                self.interactiveAnimation = UIPercentDrivenInteractiveTransition()
                self.interactiveAnimation?.completionCurve = .easeInOut
                self.dismiss(animated: true, completion: nil)
            case .changed:
                self.interactiveAnimation?.update(progress)
            case .ended: fallthrough
            case .cancelled:
                //If we have swiped over half way, or we flicked the view upward then we want to finish the transition
                if progress > 0.5 || fabs(recognizer.velocity(in: self.view).y) > flickSpeed {
                    self.interactiveAnimation?.finish()
                } else {
                    self.interactiveAnimation?.cancel()
                }
                
                self.interactiveAnimation = nil
            default: break
        }
    }
}

//MARK: - PhotoBrowserDelegate
extension PhotoBrowserViewController:PhotoBrowserDelegate {
    public func photoBrowser(_ photoBrowser: PhotoBrowserView, photoTappedAtIndex indexPath: IndexPath) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        self.interactiveAnimation?.finish()
    }
    
    public func photoBrowser(_ photoBrowser: PhotoBrowserView, photoViewedAtIndex indexPath: IndexPath) {
        self.originPhotoView?.visibleRow = -1
        self.originPhotoView?.delegate?.photoBrowser(photoBrowser, photoViewedAtIndex: indexPath)
    }
}

//MARK: - UIViewControllerTransistioningDelegate
extension PhotoBrowserViewController:UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let originImageView = self.originPhotoView?.visibleImageView() else { return nil }
        let transition = PhotoBrowserTransition()
        transition.imageView = originImageView
        transition.destinationPhotoView = self.photoView
        
        return transition
    }
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let photoImageViewController = dismissed as? PhotoBrowserViewController,
            let originPhotoView = self.originPhotoView else { return nil }
        
        let transition = PhotoBrowserTransition()
        transition.animateIn = false
        transition.imageView = photoImageViewController.photoView?.visibleImageView()
        transition.destinationPhotoView = originPhotoView
        transition.originPhotoView = photoImageViewController.photoView
        
        return transition
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let _ = animator as? PhotoBrowserTransition else { return nil }
        return self.interactiveAnimation
    }
}
