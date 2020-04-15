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
    public var imageNumberView = ImageNumberView()
    
    /// Used to animate from an origin
    var originImageView: UIImageView?
    var originNumberView: ImageNumberView?
    var interactiveAnimation: UIPercentDrivenInteractiveTransition?
    
    public var pagedView = PhotoBrowserInfinitePagedView(frame: .zero)
    
    public var previewCollectionView: PhotoBrowserPreviewCollectionView!
    
    public var initialPhotoIndex: Int = 0
    public var imageNumberFont: UIFont {
        set {
            self.imageNumberView.font = newValue
        }
        get {
            return self.imageNumberView.font
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.setup()
    }
    
    @objc func closeTapped(_ gesture: UITapGestureRecognizer) {
        let delegate = self.delegate
        delegate?.photoBrowserFullscreenWillDismiss(selectedIndex: self.pagedView.currentPage)
        self.dismiss(animated: true) {
            delegate?.photoBrowserFullscreenDidDismiss(selectedIndex: self.pagedView.currentPage)
        }
        self.interactiveAnimation?.finish()
    }
    
    func updateLabelView() {
        let photoCount = self.dataSource.numberOfPhotos()
        let currentPhoto = self.pagedView.currentPage
        self.imageNumberView.text = "\(currentPhoto + 1) of \(photoCount)"
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
        
        // Add tag gesture to close fullscreen
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.closeTapped(_:)))
        self.closeButtonContainer.addGestureRecognizer(gesture)
        
        // Add pan gesture to watch for sliding up to dismiss image
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.panGesture(_:)))
        pan.delegate = self
        self.pagedView.currentImageView.addGestureRecognizer(pan)
    }
    
    private func setupImageNumber() {
        self.view.addSubview(self.imageNumberView) {
            $0.right.pinToSuperview(inset: 16, relation: .equal)
            $0.bottom.pinToSuperviewMargin(inset: 82, relation: .equal)
        }
        
        self.updateLabelView()
    }
    
    private func setupPagedView() {
        self.view.addSubview(self.pagedView) {
            $0.edges.pinToSuperview()
        }
        
        self.pagedView.photoDelegate = self
        self.pagedView.photoDataSource = self
        self.pagedView.isZoomEnabled = true
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
    
    @objc func panGesture(_ recognizer:UIPanGestureRecognizer) {
        let flickSpeed:CGFloat = 1300
        
        //Find progress of upward swipe.
        var progress = recognizer.translation(in: self.view).y / self.view.bounds.size.height
        progress = min(1.0, abs(progress) * 2)
        
        //Update progress
        switch (recognizer.state) {
            case .began:
                self.interactiveAnimation = UIPercentDrivenInteractiveTransition()
                self.interactiveAnimation?.completionCurve = .easeInOut
                let delegate = self.delegate
                delegate?.photoBrowserFullscreenWillDismiss(selectedIndex: self.pagedView.currentPage)
                self.dismiss(animated: true) {
                    delegate?.photoBrowserFullscreenDidDismiss(selectedIndex: self.pagedView.currentPage)
                }
            case .changed:
                self.interactiveAnimation?.update(progress)
            case .ended: fallthrough
            case .cancelled:
                //If we have swiped over half way, or we flicked the view upward then we want to finish the transition
                if progress > 0.5 || abs(recognizer.velocity(in: self.view).y) > flickSpeed {
                    self.interactiveAnimation?.finish()
                } else {
                    self.interactiveAnimation?.cancel()
                }
                
                self.interactiveAnimation = nil
            default: break
        }
    }
}

extension PhotoBrowserFullscreenViewController: PhotoBrowserInfinitePagedDataSource, PhotoBrowserInfinitePagedDelegate {
    func photoBrowserInfinitePhotoViewed(at index: Int) {
        self.delegate?.photoBrowserFullscreenPhotoViewed(index)
        self.previewCollectionView?.selectedPhotoIndex = index
        self.updateLabelView()
    }
    
    func photoBrowserInfinitePhotoTapped(at index: Int) {
        self.delegate?.photoBrowserFullscreenPhotoTapped(index)
        self.previewCollectionView.selectedPhotoIndex = (self.pagedView.currentPage + 1) % self.pagedView.pageCount
        self.pagedView.scrollRectToVisible(self.pagedView.nextImageView.frame, animated: true)
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
        
        guard let presented = presented as? PhotoBrowserFullscreenViewController, let originImageView = presented.originImageView else { return nil }
        
        let transition = PhotoBrowserFullscreenTransition()
        transition.originImageView = originImageView
        transition.destinationImageView = self.pagedView.currentImageView
        transition.originNumberView = presented.originNumberView
        transition.destinationNumberView = self.imageNumberView
        
        return transition
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let dismissed = dismissed as? PhotoBrowserFullscreenViewController, let originImageView = dismissed.originImageView else { return nil }
        
        let transition = PhotoBrowserFullscreenTransition()
        transition.animateIn = false
        transition.destinationImageView = originImageView
        transition.originImageView = dismissed.pagedView.currentImageView
        transition.originNumberView = dismissed.imageNumberView
        transition.destinationNumberView = dismissed.originNumberView
        
        return transition
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let _ = animator as? PhotoBrowserFullscreenTransition else { return nil }
        return self.interactiveAnimation
    }
}

extension PhotoBrowserFullscreenViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        let velocity = panGesture.velocity(in: self.view)
        return abs(velocity.y) > abs(velocity.x);
    }
}
