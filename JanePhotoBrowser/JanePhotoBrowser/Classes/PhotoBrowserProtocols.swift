//
//  PhotoBrowserProtocols.swift
//  JanePhotoBrowser
//
//  Copyright © 2016 Jane. All rights reserved.
//

import UIKit

public protocol PhotoBrowserDataSource:class {
    func photoBrowser(photoBrowser:PhotoBrowserView, photoAtIndex index: Int, forCell cell:PhotoBrowserViewCell) -> UIImage
    func numberOfPhotos(photoBrowser:PhotoBrowserView) -> Int
}

public protocol PhotoBrowserDelegate:class {
    var photoView:PhotoBrowserView? { get set }
    func photoBrowser(photoBrowser:PhotoBrowserView, photoTappedAtIndex indexPath:NSIndexPath)
    func closeButtonTapped()
}

//Provide default implementation for UIViewController delegates
extension PhotoBrowserDelegate where Self: UIViewController {
    public func photoBrowser(photoBrowser:PhotoBrowserView, photoTappedAtIndex indexPath:NSIndexPath) {
        let photoBrowserViewController:PhotoBrowserViewController = PhotoBrowserViewController(nibName: nil, bundle: nil)
        photoBrowserViewController.photoView!.dataSource = photoBrowser.dataSource
        photoBrowserViewController.photoView!.backgroundColor = UIColor.whiteColor()
        photoBrowserViewController.transitioningDelegate = photoBrowserViewController
        photoBrowserViewController.initialIndexPath = photoBrowser.visibleIndexPath()
        photoBrowserViewController.originPhotoView = photoBrowser
        
        self.presentViewController(photoBrowserViewController, animated: true, completion: nil)
    }
    public func closeButtonTapped() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
