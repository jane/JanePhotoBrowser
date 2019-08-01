//
//  PhotoBrowserInfinitePagedDelegate.swift
//  PhotoBrowser
//
//  Created by Gordon Tucker on 8/1/19.
//  Copyright © 2019 Jane. All rights reserved.
//

import UIKit

protocol PhotoBrowserInfinitePagedDataSource: class {
    func photoBrowserInfiniteLoadPhoto(_ index: Int, forImageView imageView: UIImageView, completion: @escaping (UIImage?) -> ())
    func numberOfPhotos() -> Int
}
