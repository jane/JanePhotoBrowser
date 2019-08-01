//
//  PhotoBrowserFullscreenViewController.swift
//  PhotoBrowser
//
//  Created by Gordon Tucker on 8/1/19.
//  Copyright © 2019 Jane. All rights reserved.
//

import UIKit

public class PhotoBrowserFullscreenViewController: UIViewController {

    weak var delegate: PhotoBrowserFullscreenDelegate!
    weak var dataSource: PhotoBrowserFullscreenDataSource!
    
    public var closeButton = UIImageView()
    public var closeButtonContainer = UIView()
    public var imageNumberLabel: UILabel = UILabel()
    public var imageNumberContainerView: UIView = UIView()
    /// Used to animate from an origin
    public var originImageView: UIImageView?
    
    public var pagedView = PhotoBrowserInfinitePagedView(frame: .zero)
    
    public var previewCollectionView: PhotoBrowserPreviewCollectionView!
    
    public var initialPhotoIndex: Int = 0
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.setup()
    }
    
    @objc func closeTapped(_ gesture: UITapGestureRecognizer) {
        self.delegate.photoBrowserFullscreenCloseButtonTapped(selectedIndex: self.pagedView.currentPage)
    }
    
    func updateLabelView() {
        let photoCount = self.dataSource.numberOfPhotos()
        let currentPhoto = self.pagedView.currentPage
        self.imageNumberLabel.text = "\(currentPhoto + 1) of \(photoCount)"
    }
    
    private func setup() {
        self.setupPagedView()
        self.setupPreviewCollection()
        self.setupCloseButton()
        self.setupImageNumber()
    }
    
    private func setupCloseButton() {
        self.view.addSubview(self.closeButtonContainer) {
            $0.right.pinToSuperview(inset: 16, relation: .equal)
            $0.top.pinToSuperviewMargin(inset: 16, relation: .equal)
        }
        
        self.closeButtonContainer.layer.cornerRadius = 4
        self.closeButtonContainer.layer.masksToBounds = true
        self.closeButtonContainer.backgroundColor = UIColor.clear
        self.closeButtonContainer.isAccessibilityElement = true
        self.closeButtonContainer.accessibilityTraits = [.button]
        self.closeButtonContainer.accessibilityLabel = "Close"
        self.closeButtonContainer.accessibilityHint = "Tap to close fullscreen image browser"
        
        // Add a blur view so we get a nice effect behind the number count
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.closeButtonContainer.addSubview(blurEffectView) {
            $0.edges.pinToSuperview()
        }
        
        self.closeButton.isAccessibilityElement = false
        self.closeButton.image = PhotoBrowserIconography.imageOfXIcon()
        self.closeButton.backgroundColor = .clear
        
        self.closeButtonContainer.addSubview(self.closeButton) {
            $0.edges.pinToSuperview(insets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8), relation: .equal)
            $0.height.set(24)
            $0.width.set(24)
        }
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.closeTapped(_:)))
        self.closeButtonContainer.addGestureRecognizer(gesture)
    }
    
    private func setupImageNumber() {
        self.view.addSubview(self.imageNumberContainerView) {
            $0.right.pinToSuperview(inset: 16, relation: .equal)
            $0.bottom.pinToSuperviewMargin(inset: 66, relation: .equal)
        }
        
        self.imageNumberContainerView.layer.cornerRadius = 4
        self.imageNumberContainerView.layer.masksToBounds = true
        self.imageNumberContainerView.backgroundColor = UIColor.clear
        
        // Add a blur view so we get a nice effect behind the number count
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.imageNumberContainerView.addSubview(blurEffectView) {
            $0.edges.pinToSuperview()
        }
        
        self.imageNumberLabel.textColor = UIColor(red: 0.07, green: 0.07, blue: 0.07, alpha: 1)
        self.imageNumberLabel.isAccessibilityElement = false
        
        self.imageNumberContainerView.addSubview(self.imageNumberLabel) {
            $0.edges.pinToSuperview(insets: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 15), relation: .equal)
        }
        
        self.updateLabelView()
    }
    
    private func setupPagedView() {
        self.view.addSubview(self.pagedView) {
            $0.edges.pinToSuperview()
        }
        
        self.pagedView.photoDelegate = self
        self.pagedView.photoDataSource = self
        self.pagedView.reloadPhotos(at: self.initialPhotoIndex)
    }
    
    private func setupPreviewCollection() {
        self.previewCollectionView = PhotoBrowserPreviewCollectionView(dataSource: self, delegate: self)
        
        // Add a blur view so we get a nice effect behind the number count
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.view.addSubview(blurEffectView) {
            $0.edges(.left, .right, .bottom).pinToSuperview()
        }
        
        blurEffectView.contentView.addSubview(self.previewCollectionView) {
            $0.edges(.left, .right).pinToSuperview()
            $0.top.pinToSuperview(inset: 8, relation: .equal)
            $0.bottom.pinToSafeArea(of: self, inset: 8, relation: .equal)
            $0.height.set(50)
        }
        
        let border = UIView()
        border.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        blurEffectView.contentView.addSubview(border) {
            $0.edges(.left, .top, .right).pinToSuperview()
            $0.height.set((1.0 / UIScreen.main.scale))
        }
        
        self.previewCollectionView.selectedPhotoIndex = self.initialPhotoIndex
    }
}

extension PhotoBrowserFullscreenViewController: PhotoBrowserInfinitePagedDataSource, PhotoBrowserInfinitePagedDelegate {
    func photoBrowserInfinitePhotoViewed(at index: Int) {
        self.delegate?.photoBrowserFullscreenPhotoViewed(index)
    }
    
    func photoBrowserInfinitePhotoTapped(at index: Int) {
        self.delegate?.photoBrowserFullscreenPhotoTapped(index)
    }
    
    func photoBrowserInfiniteLoadPhoto(_ index: Int, forImageView imageView: UIImageView, completion: @escaping (UIImage?) -> ()) {
        self.dataSource?.photoBrowserFullscreenLoadPhoto(index, forImageView: imageView, completion: completion)
    }
}

extension PhotoBrowserFullscreenViewController: PhotoBrowserPreviewDataSource, PhotoBrowserPreviewDelegate {
    func photoBrowserPreviewLoadThumbnail(_ index: Int, forImageView imageView: UIImageView, completion: @escaping (UIImage?) -> ()) {
        self.dataSource.photoBrowserFullscreenLoadThumbanil(index, forImageView: imageView, completion: completion)
    }
    
    func numberOfPhotos() -> Int {
        return self.dataSource.numberOfPhotos()
    }
    
    func photoBrowserPreviewThumbnailViewed(at index: Int) {
        self.delegate.photoBrowserFullscreenThumbnailViewed(index)
    }
    
    func photoBrowserPreviewThumbnailTapped(at index: Int) {
        self.delegate.photoBrowserFullscreenThumbnailTapped(index)
        self.pagedView.reloadPhotos(at: index)
    }
}

extension PhotoBrowserFullscreenViewController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        guard let presented = presented as? PhotoBrowserFullscreenViewController, let originView = presented.originImageView else { return nil }
        
        let transition = PhotoBrowserFullscreenTransition()
        transition.destinationView = presented.pagedView.currentImageView
        transition.sourceView = originView
        transition.animateIn = true
        
        return transition
    }
}
