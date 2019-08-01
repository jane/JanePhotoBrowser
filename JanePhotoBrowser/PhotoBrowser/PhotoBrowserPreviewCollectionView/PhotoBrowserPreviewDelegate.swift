//
//  PhotoBrowserPreviewDelegate.swift
//  PhotoBrowser
//
//  Created by Gordon Tucker on 8/1/19.
//  Copyright © 2019 Jane. All rights reserved.
//

import UIKit

protocol PhotoBrowserPreviewDelegate: class {
    func photoBrowserPreviewThumbnailViewed(at index: Int)
    func photoBrowserPreviewThumbnailTapped(at index: Int)
}
