//
//  PhotoBrowserInfinitePagedDelegate.swift
//  PhotoBrowser
//
//  Created by Gordon Tucker on 8/1/19.
//  Copyright © 2019 Jane. All rights reserved.
//

import UIKit

protocol PhotoBrowserInfinitePagedDelegate: class {
    func photoBrowserInfinitePhotoViewed(at index: Int)
    func photoBrowserInfinitePhotoTapped(at index: Int)
    func photoBrowserInfinitePhotoZoom(at index: Int)
}
