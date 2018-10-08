//
//  PhotoBrowserProtocols.swift
//  JanePhotoBrowser
//
//  Copyright © 2016 Jane. All rights reserved.
//

import UIKit

public protocol PhotoBrowserDataSource:class {
    func photoBrowser(_ photoBrowser:PhotoBrowserView, photoAtIndex index: Int, forCell cell:PhotoBrowserCell, completion: @escaping (UIImage?) -> ())
    func numberOfPhotos(_ photoBrowser:PhotoBrowserView) -> Int
}

public protocol PhotoBrowserDelegate:class {
    var photoView:PhotoBrowserView? { get set }
    func photoBrowser(_ photoBrowser: PhotoBrowserView, photoTappedAtIndex indexPath: IndexPath)
    func photoBrowser(_ photoBrowser: PhotoBrowserView, photoViewedAtIndex indexPath: IndexPath)
    func photoBrowserCloseButtonTapped()
}

extension PhotoBrowserDelegate {
    public func photoBrowser(_ photoBrowser: PhotoBrowserView, photoViewedAtIndex indexPath: IndexPath) { }
}

//Provide default implementation for UIViewController delegates
extension PhotoBrowserDelegate where Self: UIViewController {
    public func photoBrowser(_ photoBrowser:PhotoBrowserView, photoTappedAtIndex indexPath:IndexPath) {
        let photoBrowserViewController:PhotoBrowserViewController = PhotoBrowserViewController(nibName: nil, bundle: nil)
        photoBrowserViewController.photoView!.dataSource = photoBrowser.dataSource
        photoBrowserViewController.photoView!.backgroundColor = UIColor.white
        photoBrowserViewController.transitioningDelegate = photoBrowserViewController
        photoBrowserViewController.initialIndexPath = photoBrowser.visibleIndexPath()
        photoBrowserViewController.originPhotoView = photoBrowser
        photoBrowserViewController.delegate = photoBrowser
        
        self.present(photoBrowserViewController, animated: true, completion: nil)
    }
    public func photoBrowserCloseButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}
