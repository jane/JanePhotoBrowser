//
//  PhotoBrowserViewController.swift
//  JanePhotoBrowser
//
//  Copyright © 2016 Jane. All rights reserved.
//

import UIKit

public protocol PhotoBrowserViewControllerDelegate: class {
    func photoBrowser(_ photoBrowser: PhotoBrowserViewController, photoViewedAtIndex indexPath: IndexPath)
}

public class PhotoBrowserViewController: UIViewController {
    //MARK: - Private Variables
    fileprivate var interactiveAnimation: UIPercentDrivenInteractiveTransition?
    
    //MARK: - Variables
    public var initialIndexPath : IndexPath?
    weak public var originPhotoView: PhotoBrowserView? {
        didSet {
            // Make sure the label is updated to be the right number and triggers a view event
            if self.originPhotoView?.visibleRow == 1 {
                self.photoView?.visibleRow = -1
            }
            self.photoView?.showPreview = self.originPhotoView?.showFullScreenPreview ?? false
            self.photoView?.updateLabelView()
        }
    }
    public var photoView:PhotoBrowserView? = PhotoBrowserView()
    public weak var delegate: PhotoBrowserViewControllerDelegate?
    
    //MARK: - UIViewController
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        guard let photoView = self.photoView else { return }
        self.view.addSubview(photoView)
        
        photoView.canZoom = true
        photoView.translatesAutoresizingMaskIntoConstraints = false
        photoView.delegate = self
        photoView.shouldDisplayCloseButton = true
        
        //Setup Layout for PhotoView
        let formatString = self.photoView?.showPreview == true ? "V:|[view]-|" : "V:|[view]|"
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: formatString, options: [], metrics: nil, views: ["view":photoView])
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: ["view":photoView])
        self.view.addConstraints(vConstraints)
        self.view.addConstraints(hConstraints)
        
        //Add pan gesture to watch for sliding up to dismiss image
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.panGesture(_:)))
        photoView.addGestureRecognizer(pan)
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let indexPath = self.initialIndexPath, let photoView = self.photoView else { return }
        photoView.scrollToPhoto(atIndex: (indexPath as NSIndexPath).item, animated: false)
    }
    
    @objc func panGesture(_ recognizer:UIPanGestureRecognizer) {
        let flickSpeed:CGFloat = 1300
        
        //Find progress of upward swipe.
        var progress = recognizer.translation(in: self.view).y / self.view.bounds.size.height
        progress = min(1.0, abs(progress) * 2)
        
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
                if progress > 0.5 || abs(recognizer.velocity(in: self.view).y) > flickSpeed {
                    self.interactiveAnimation?.finish()
                } else {
                    self.interactiveAnimation?.cancel()
                }
                
                self.interactiveAnimation = nil
            default: break
        }
    }
    
    public static func instantiate(photoBrowser: PhotoBrowserView) -> PhotoBrowserViewController {
        let controller = PhotoBrowserViewController(nibName: nil, bundle: nil)
        controller.photoView!.dataSource = photoBrowser.dataSource
        controller.photoView!.backgroundColor = UIColor.white
        controller.transitioningDelegate = controller
        controller.initialIndexPath = photoBrowser.visibleIndexPath()
        controller.originPhotoView = photoBrowser
        controller.delegate = photoBrowser
        
        return controller
    }
}

//MARK: - PhotoBrowserDelegate
extension PhotoBrowserViewController:PhotoBrowserDelegate {
    public func photoBrowser(_ photoBrowser: PhotoBrowserView, photoTappedAtIndex indexPath: IndexPath) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        self.interactiveAnimation?.finish()
    }
    
    public func photoBrowser(_ photoBrowser: PhotoBrowserView, photoViewedAtIndex indexPath: IndexPath) {
        self.delegate?.photoBrowser(self, photoViewedAtIndex: indexPath)
    }
    
    public func photoBrowserCloseButtonTapped() {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        self.interactiveAnimation?.finish()
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
