//
//  PhotoBrowserViewController.swift
//  JanePhotoBrowser
//
//  Copyright © 2016 Jane. All rights reserved.
//

import UIKit

class PhotoBrowserViewController: UIViewController {
    var initialIndexPath : NSIndexPath?
    
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
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let indexPath = self.initialIndexPath,
            let photoView = self.photoView else { return }
        photoView.scrollToPhoto(atIndex: indexPath.item, animated: false)
    }
}

extension PhotoBrowserViewController:PhotoBrowserDelegate {
    func photoBrowser(photoBrowser: PhotoBrowserView, photoTappedAtIndex indexPath: NSIndexPath) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}

//extension PhotoBrowserViewController: UINavigationControllerDelegate {
//    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        guard let toVC = toVC as? PhotoBrowserDelegate,
//            let photoView = self.photoView where fromVC == self else { return nil }
//        
//        let transition = PhotoBrowserAnimateOutTransition()
//        
//        transition.imageView = photoView.selectedImageView
//        transition.destinationPhotoView = toVC.photoView
//        
//        return transition
//    }
//}
//
//extension PhotoBrowserViewController:UIViewControllerTransitioningDelegate {
//    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        guard let toVC = presenting as? PhotoBrowserDelegate,
//            let photoView = self.photoView where source == self else { return nil }
//        
//        let transition = PhotoBrowserAnimateOutTransition()
//        
//        transition.imageView = photoView.selectedImageView
//        transition.destinationPhotoView = toVC.photoView
//        
//        return transition
//    }
//}