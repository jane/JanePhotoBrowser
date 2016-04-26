//
//  PhotoBrowserViewController.swift
//  JanePhotoBrowser
//
//  Copyright © 2016 Jane. All rights reserved.
//

import UIKit

class PhotoBrowserViewController: UIViewController {
    var initialIndexPath : NSIndexPath?
    
    var photoView:PhotoBrowserView = PhotoBrowserView()
    
    override func viewDidLoad() {
        self.view.addSubview(self.photoView)
        self.photoView.canZoom = true
        self.photoView.translatesAutoresizingMaskIntoConstraints = false
        
        self.photoView.delegate = self
        
        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: [], metrics: nil, views: ["view":self.photoView])
        let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: [], metrics: nil, views: ["view":self.photoView])
        self.view.addConstraints(vConstraints)
        self.view.addConstraints(hConstraints)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let indexPath = self.initialIndexPath else { return }
        self.photoView.scrollToPhoto(atIndex: indexPath.item, animated: false)
    }
}

extension PhotoBrowserViewController:PhotoBrowserDelegate {
    func photoBrowser(photoBrowser: PhotoBrowserView, photoTappedAtIndex indexPath: NSIndexPath) {
        
    }
}