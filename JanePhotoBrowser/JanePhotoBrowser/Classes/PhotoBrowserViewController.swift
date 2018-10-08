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
    //MARK: - Variables
    fileprivate var interactiveAnimation: UIPercentDrivenInteractiveTransition?
    
    public var initialIndexPath: IndexPath!
    public var photoView: PhotoBrowserView? = PhotoBrowserView()
    public weak var delegate: PhotoBrowserViewControllerDelegate?
    
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
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: ["view":photoView])
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: ["view":photoView])
        self.view.addConstraints(vConstraints)
        self.view.addConstraints(hConstraints)
        
        if let indexPath = self.initialIndexPath, let photoView = self.photoView {
            self.initialIndexPath = nil
            photoView.scrollToPhoto(atIndex: (indexPath as NSIndexPath).item, animated: false)
        }
        
        //Add pan gesture to watch for sliding up to dismiss image
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.panGesture(_:)))
        photoView.addGestureRecognizer(pan)
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc func panGesture(_ recognizer:UIPanGestureRecognizer) {
        let flickSpeed:CGFloat = 1300
        
        //Find progress of upward swipe.
        var progress = recognizer.translation(in: self.view).y / self.view.bounds.size.height
        progress = min(1.0, abs(progress) * 2)
        
        //Update progress
        switch (recognizer.state) {
            case .began:
                self.view.alpha = 1
                self.photoView?.alpha = 1
            case .changed:
                self.view.alpha = max(0, 1 - progress)
                self.photoView?.alpha = min(1, self.view.alpha * 2)
            case .ended:
                self.dismiss(animated: false, completion: nil)
            case .cancelled:
                //If we have swiped over half way, or we flicked the view upward then we want to finish the transition
                if progress > 0.5 || abs(recognizer.velocity(in: self.view).y) > flickSpeed {
                    self.dismiss(animated: false, completion: nil)
                } else {
                    UIView.animate(withDuration: 0.2) {
                        self.view.alpha = 1
                        self.photoView?.alpha = 1
                    }
                }
            default: break
        }
    }
        
    public static func instantiate(dataSource: PhotoBrowserDataSource, delegate: PhotoBrowserViewControllerDelegate, indexPath: IndexPath? = nil) -> PhotoBrowserViewController {
        let photoBrowserViewController:PhotoBrowserViewController = PhotoBrowserViewController(nibName: nil, bundle: nil)
        photoBrowserViewController.photoView!.dataSource = dataSource
        photoBrowserViewController.photoView!.backgroundColor = UIColor.white
        photoBrowserViewController.initialIndexPath = indexPath
        photoBrowserViewController.delegate = delegate
        photoBrowserViewController.transitioningDelegate = photoBrowserViewController
        //photoBrowserViewController.modalTransitionStyle = .crossDissolve
        //photoBrowserViewController.modalPresentationStyle = .overFullScreen
        
        return photoBrowserViewController
    }
    
}

//MARK: - PhotoBrowserDelegate
extension PhotoBrowserViewController: PhotoBrowserDelegate {
    public func photoBrowser(_ photoBrowser: PhotoBrowserView, photoTappedAtIndex indexPath: IndexPath) {
        self.dismiss(animated: true, completion: nil)
    }
    
    public func photoBrowser(_ photoBrowser: PhotoBrowserView, photoViewedAtIndex indexPath: IndexPath) {
        self.delegate?.photoBrowser(self, photoViewedAtIndex: indexPath)
    }
    
    public func photoBrowserCloseButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - UIViewControllerTransistioningDelegate
extension PhotoBrowserViewController:UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let source = source as? PhotoBrowserDelegate, let originView = source.photoView else { return nil }
        let transition = PhotoBrowserTransition()
        transition.originView = originView
        transition.destinationView = self.photoView
        transition.image = originView.visibleImageView()?.image
        
        return transition
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let dismissed = dismissed as? PhotoBrowserViewController else { return nil }
        guard let destination = dismissed.presentingViewController as? PhotoBrowserDelegate, let destinationView = destination.photoView else { return nil }
        
        let transition = PhotoBrowserTransition()
        transition.animateIn = false
        transition.originView = dismissed.photoView
        transition.destinationView = destinationView
        transition.image = dismissed.photoView?.visibleImageView()?.image
        
        return transition
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let _ = animator as? PhotoBrowserTransition else { return nil }
        return self.interactiveAnimation
    }
}
