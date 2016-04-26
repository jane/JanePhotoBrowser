//
//  PhotoBrowserProtocols.swift
//  JanePhotoBrowser
//
//  Copyright © 2016 Jane. All rights reserved.
//

import UIKit

protocol PhotoBrowserDataSource:class {
    func photoBrowser(photoBrowser:PhotoBrowserView, photoAtIndex index: Int) -> UIImage
    func numberOfPhotos(photoBrowser:PhotoBrowserView) -> Int
}

protocol PhotoBrowserDelegate:class {
    func photoBrowser(photoBrowser:PhotoBrowserView, photoTappedAtIndex index:Int)
    func closeButtonTapped()
}
