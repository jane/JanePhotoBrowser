//
//  PhotoBrowserDataSource.swift
//  JanePhotoBrowser
//
//  Created by Gordon Tucker on 8/1/19.
//  Copyright © 2019 Jane. All rights reserved.
//

import UIKit

public protocol PhotoBrowserDataSource: class {
    func photoBrowser(_ photoBrowser:PhotoBrowserView, photoAtIndex index: Int, forImageView imageView: UIImageView, completion: @escaping (UIImage?) -> ())
    func photoBrowser(_ photoBrowser:PhotoBrowserView, thumbnailAtIndex index: Int, forImageView imageView: UIImageView, completion: @escaping (UIImage?) -> ())
    func numberOfPhotos(_ photoBrowser:PhotoBrowserView) -> Int
}

public extension PhotoBrowserDataSource {
    func photoBrowser(_ photoBrowser:PhotoBrowserView, thumbnailAtIndex index: Int, forImageView imageView: UIImageView, completion: @escaping (UIImage?) -> ()) {
        self.photoBrowser(photoBrowser, photoAtIndex: index, forImageView: imageView, completion: completion)
    }
}
