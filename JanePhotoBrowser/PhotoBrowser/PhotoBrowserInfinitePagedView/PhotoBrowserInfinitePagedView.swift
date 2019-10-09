//
//  PhotoBrowserInfinitePagedView.swift
//  PhotoBrowser
//
//  Created by Gordon Tucker on 8/1/19.
//  Copyright © 2019 Jane. All rights reserved.
//

import UIKit

public class PhotoBrowserInfinitePagedView: UIScrollView {
    enum PhotoPosition: Int {
        case previous = 0
        case current = 1
        case next = 2
    }
    
    weak var photoDataSource: PhotoBrowserInfinitePagedDataSource?
    weak var photoDelegate: PhotoBrowserInfinitePagedDelegate?
    var currentPage: Int = 0 {
        didSet {
            self.updateAccessibilityLabel()
        }
    }
    var pageCount: Int {
        return self.photoDataSource?.numberOfPhotos() ?? 0
    }
    var zoomScrollView = PhotoBrowserZoomScrollView()
    var imageViews: [UIImageView] {
        return [previousImageView, currentImageView, nextImageView]
    }
    var previousImageView = UIImageView()
    var currentImageView = UIImageView()
    var nextImageView = UIImageView()
    var isZoomEnabled: Bool = false {
        didSet {
            self.zoomScrollView.isZoomEnabled = self.isZoomEnabled
        }
    }
    
    private var currentPageWidth: CGFloat = UIScreen.main.bounds.width
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.showsHorizontalScrollIndicator = false
        self.bounces = false
        self.isPagingEnabled = true
        self.isUserInteractionEnabled = true
        self.isScrollEnabled = true
        self.delegate = self
        
        self.setupImageViews()
        self.reloadPhotos()
        self.backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func layoutSubviews() {
        if self.currentPageWidth != self.bounds.width {
            self.updateImageViewLayout()
            self.currentPageWidth = self.bounds.width
        }
        super.layoutSubviews()
    }
    
    private func setupImageViews() {
        self.imageViews.forEach {
            $0.contentMode = .scaleAspectFit
            $0.backgroundColor = .clear
        }
        
        var previousView: UIView?
        for view in [self.previousImageView, self.zoomScrollView, self.nextImageView] {
            self.addSubview(view)
            if let previousView = previousView {
                Constraints(for: view, previousView) { view, previousView in
                    view.edges(.top, .bottom).pinToSuperview()
                    view.left.align(with: previousView.right)
                    view.size.match(previousView.size)
                }
            } else {
                Constraints(for: view, self) { view, scrollView in
                    view.edges(.top, .bottom, .left).pinToSuperview()
                    view.size.match(scrollView.size)
                }
            }
            previousView = view
        }
        _ = previousView.flatMap({
            Constraints(for: $0) {
                $0.edges(.right).pinToSuperview()
            }
        })
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped(_:)))
        self.currentImageView.addGestureRecognizer(gesture)
        self.currentImageView.isUserInteractionEnabled = true
        self.currentImageView.isAccessibilityElement = true
        self.currentImageView.accessibilityHint = "Tap to view images full screen"
        self.updateImageViewLayout()
        
        self.zoomScrollView.setup(with: self.currentImageView)
    }
    
    @objc func imageTapped(_ sender: UITapGestureRecognizer?) {
        self.photoDelegate?.photoBrowserInfinitePhotoTapped(at: self.currentPage)
    }
    
    func reloadPhotos(at index: Int? = nil) {
        if let index = index {
            // If they are focing an index, override current page here
            self.currentPage = min(max(0, index), self.pageCount - 1)
        }
        self.resetZoom()
        self.imageViews.forEach({ $0.image = nil })
        loadImage(at: self.currentPage, forPosition: .current)
        loadImage(at: self.currentPage + 1, forPosition: .next)
        loadImage(at: self.currentPage - 1, forPosition: .previous)
        if self.pageCount > 0 {
            self.photoDelegate?.photoBrowserInfinitePhotoViewed(at: self.currentPage)
        }
        self.updateAccessibilityLabel()
    }
    
    private func correctedIndex(_ index: Int) -> Int {
        let photoCount = self.pageCount
        var adjustedIndex = index
        while adjustedIndex < 0 {
            adjustedIndex += photoCount
        }
        while adjustedIndex >= photoCount {
            adjustedIndex -= photoCount
        }
        return adjustedIndex
    }
    
    func loadImage(at index: Int, forPosition position: PhotoPosition) {
        guard self.pageCount > 0 else { return }
        let index = self.correctedIndex(index)
        let imageView = self.imageViews[position.rawValue]
        
        self.photoDataSource?.photoBrowserInfiniteLoadPhoto(index, forImageView: imageView) { [weak self] (image) in
            guard let self = self else { return }
            
            if index == self.currentPage {
                self.currentImageView.image = image
            } else if self.correctedIndex(index + 1) == self.currentPage {
                self.previousImageView.image = image
            } else if self.correctedIndex(index - 1) == self.currentPage {
                self.nextImageView.image = image
            }
        }
    }
    
    private func updateAccessibilityLabel() {
        self.currentImageView.accessibilityLabel = "Image \(self.currentPage + 1) of \(self.pageCount)"
    }
    
    /// Update the image view layout so each image is the full width of the paged view
    private func updateImageViewLayout() {
        self.currentPageWidth = self.bounds.width
        self.setContentOffset(CGPoint(x: self.currentPageWidth, y: 0), animated: false)
    }
    
    func resetZoom() {
        self.zoomScrollView.zoomScale = 1
    }
    
    func zoomIn() {
        self.zoomScrollView.zoomScale = 2
    }
}

extension PhotoBrowserInfinitePagedView: UIScrollViewDelegate {
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.calculatePageChange()
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.calculatePageChange()
    }
    
    private func calculatePageChange() {
        // Once we finish scrolling, move back to the middle
        var newPage: Int = self.currentPage
        
        if self.contentOffset.x < 10 {
            newPage -= 1
        } else if self.contentOffset.x > self.currentPageWidth * 1.5 {
            newPage += 1
        } else {
            // Nothing changed, do nothing here
            return
        }
        
        let photoCount = self.pageCount
        if photoCount == 0 || newPage >= photoCount {
            self.currentPage = 0
        } else if newPage < 0 {
            self.currentPage = photoCount - 1
        } else {
            self.currentPage = newPage
        }
        
        if self.contentOffset.x < 10 {
            // We moved backwards
            self.nextImageView.image = self.currentImageView.image
            self.currentImageView.image = self.previousImageView.image
            self.previousImageView.image = nil
            self.loadImage(at: self.currentPage - 1, forPosition: .previous)
            self.resetZoom()
        } else if self.contentOffset.x > self.currentPageWidth * 1.5 {
            // We moved forwards
            self.previousImageView.image = self.currentImageView.image
            self.currentImageView.image = self.nextImageView.image
            self.nextImageView.image = nil
            self.loadImage(at: self.currentPage + 1, forPosition: .next)
        }
        self.resetZoom()
        self.contentOffset = CGPoint(x: self.currentPageWidth, y: 0)
        if photoCount > 0 {
            self.photoDelegate?.photoBrowserInfinitePhotoViewed(at: self.currentPage)
        }
        UIAccessibility.post(notification: .layoutChanged, argument: self.currentImageView)
    }
}

extension PhotoBrowserInfinitePagedView: UIScrollViewAccessibilityDelegate {
    public func accessibilityScrollStatus(for scrollView: UIScrollView) -> String? {
        return "  "
    }
}
