//
//  PhotoBrowserZoomHandler.swift
//  PhotoBrowser
//
//  Created by Gordon Tucker on 8/1/19.
//  Copyright © 2019 Jane. All rights reserved.
//

import UIKit

class PhotoBrowserZoomScrollView: UIScrollView, UIScrollViewDelegate {
    var imageView: UIImageView?
    var isZoomEnabled: Bool = false {
        didSet {
            self.zoomScale = 1
        }
    }
    
    var willBeginZooming: (() -> Void)?
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.isZoomEnabled ? self.imageView : nil
    }
    
    func setup(with imageView: UIImageView) {
        self.addSubview(imageView) {
            $0.edges.pinToSuperview()
            $0.size.match(self.al.size)
        }
        self.imageView = imageView
        self.delegate = self
        self.maximumZoomScale = 5
        self.minimumZoomScale = 1
        self.bouncesZoom = false
        self.zoomScale = 1
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        self.willBeginZooming?()
    }
}
