//
//  PhotoBrowserFullscreenDelegate.swift
//  PhotoBrowser
//
//  Created by Gordon Tucker on 8/1/19.
//  Copyright © 2019 Jane. All rights reserved.
//

import UIKit

protocol PhotoBrowserFullscreenDelegate: class {
    func photoBrowserFullscreenPhotoZoom(_ index: Int)
    func photoBrowserFullscreenPhotoTapped(_ index: Int)
    func photoBrowserFullscreenThumbnailTapped(_ index: Int)
    func photoBrowserFullscreenPhotoViewed(_ index: Int)
    func photoBrowserFullscreenThumbnailViewed(_ index: Int)
    func photoBrowserFullscreenWillDismiss(selectedIndex: Int)
    func photoBrowserFullscreenDidDismiss(selectedIndex: Int)
}
