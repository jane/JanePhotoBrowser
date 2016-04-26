//
//  PhotoBrowserViewController.swift
//  JanePhotoBrowser
//
//  Copyright © 2016 Jane. All rights reserved.
//

import UIKit

class PhotoBrowserViewController: UIViewController {
    var initialIndexPath : NSIndexPath?
    
    var PhotoView:PhotoBrowserView = PhotoBrowserView()
    
    override func viewDidLoad() {
        self.view.addSubview(self.PhotoView)
        self.PhotoView.canZoom = true
        self.PhotoView.translatesAutoresizingMaskIntoConstraints = false
        
        self.PhotoView.delegate = self
        
        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: [], metrics: nil, views: ["view":self.PhotoView])
        let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: [], metrics: nil, views: ["view":self.PhotoView])
        self.view.addConstraints(vConstraints)
        self.view.addConstraints(hConstraints)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let indexPath = self.initialIndexPath else { return }
        self.PhotoView.scrollToPhoto(atIndex: indexPath.item, animated: false)
    }
}

extension PhotoBrowserViewController:PhotoBrowserDelegate {
    func photoBrowser(photoBrowser: PhotoBrowserView, photoTappedAtIndex indexPath: NSIndexPath) {
        
    }
}