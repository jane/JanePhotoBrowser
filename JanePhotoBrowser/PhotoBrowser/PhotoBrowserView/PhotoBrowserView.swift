//
//  PhotoBrowserView.swift
//  JanePhotoBrowser
//
//  Copyright © 2016 Jane. All rights reserved.
//

import UIKit

@IBDesignable
public class PhotoBrowserView: UIView {
    
    //MARK: - Variables
    
    public weak var dataSource: PhotoBrowserDataSource? {
        didSet {
            self.pagedView.reloadPhotos()
            self.previewCollectionView?.reloadData()
            self.updateLabelView()
        }
    }
    public weak var delegate: PhotoBrowserDelegate?
    
    public var pagedView = PhotoBrowserInfinitePagedView()
    public var previewCollectionView: PhotoBrowserPreviewCollectionView?
    public var imageView: UIImageView {
        return pagedView.currentImageView
    }
    public var imageNumberView = ImageNumberView()
    public var imageNumberFont: UIFont {
        set {
            self.imageNumberView.font = newValue
        }
        get {
            return self.imageNumberView.font
        }
    }
    
    /// The index of the current photo being shown
    public var currentPhotoIndex: Int = 0
    
    /// Flag indicating if the preview thumbnails should show or not
    @IBInspectable public var showPreview: Bool = false {
        didSet {
            if self.showPreview {
                self.setupPreviewCollectionView()
            } else {
                self.previewCollectionView?.removeFromSuperview()
                self.previewCollectionView = nil
            }
            self.updateBottomConstraintsForPreviewState()
        }
    }
    
    /// Flag indicating if the (n of x) labe should show or not
    @IBInspectable public var showImageNumber: Bool = true {
        didSet {
            self.imageNumberView.isHidden = !self.showImageNumber
        }
    }
    
    @IBInspectable public var isZoomEnabled: Bool = false {
        didSet {
            self.pagedView.isZoomEnabled = self.isZoomEnabled
        }
    }
    
    private var numberViewBottomConstraint: NSLayoutConstraint?
    private var pagedViewBottomConstraint: NSLayoutConstraint?
    private var previewCollectionViewHeight: CGFloat = 58
    
    //MARK: - UIView
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    public init() {
        super.init(frame:CGRect.zero)
        self.setup()
    }
    
    public func presentFullscreen(from controller: UIViewController) {
        let fullscreenController = PhotoBrowserFullscreenViewController()
        fullscreenController.delegate = self
        fullscreenController.dataSource = self
        fullscreenController.initialPhotoIndex = self.pagedView.currentPage
        fullscreenController.originImageView = self.pagedView.currentImageView
        fullscreenController.originNumberView = self.imageNumberView
        fullscreenController.imageNumberFont = self.imageNumberFont
        fullscreenController.loadViewIfNeeded()
        fullscreenController.modalPresentationStyle = .fullScreen
        fullscreenController.transitioningDelegate = fullscreenController
        
        controller.present(fullscreenController, animated: true, completion: nil)
    }
    
    func updateLabelView() {
        let photoCount = self.dataSource?.numberOfPhotos(self) ?? 0
        let currentPhoto = self.pagedView.currentPage
        self.imageNumberView.text = "\(currentPhoto + 1) of \(photoCount)"
    }
    
    //MARK: - Private PhotoBrowser Methods
    
    private func setup() {
        self.setupPagedView()
        self.setupPreviewCollectionView()
        self.setupImageNumber()
    }
    
    private func setupPagedView() {
        self.addSubview(self.pagedView) {
            $0.edges(.top, .left, .right).pinToSuperview()
            self.pagedViewBottomConstraint = $0.bottom.pinToSuperview()
        }
        self.pagedView.photoDelegate = self
        self.pagedView.photoDataSource = self
    }
    
    private func setupPreviewCollectionView() {
        self.updateBottomConstraintsForPreviewState()
        guard self.showPreview, self.previewCollectionView == nil else { return }
        let previewCollectionView = PhotoBrowserPreviewCollectionView(dataSource: self, delegate: self)
        self.addSubview(previewCollectionView) {
            $0.edges(.left, .bottom, .right).pinToSuperview()
            $0.height.set(50)
        }
        // Set photodatasource
        previewCollectionView.selectedPhotoIndex = self.currentPhotoIndex
        self.previewCollectionView = previewCollectionView
    }
    
    private func updateBottomConstraintsForPreviewState() {
        let bottomModifier: CGFloat = self.showPreview ? -self.previewCollectionViewHeight : 0
        self.pagedViewBottomConstraint?.constant = bottomModifier
        self.numberViewBottomConstraint?.constant = bottomModifier - 16
    }
    
    private func setupImageNumber() {
        self.addSubview(self.imageNumberView) {
            $0.right.pinToSuperview(inset: 16, relation: .equal)
            self.numberViewBottomConstraint = $0.bottom.pinToSuperview(inset: 16, relation: .equal)
        }
        
        self.updateLabelView()
    }
    
    //MARK: - PhotoBrowser Methods
    
    public func scrollToPhoto(_ index:Int) {
        guard index < self.dataSource?.numberOfPhotos(self) ?? 0 && index >= 0 else {
            self.reloadPhotos()
            return
        }
        
        self.pagedView.reloadPhotos(at: index)
        
        let indexPath:IndexPath = IndexPath(row: index, section: 0)
        self.previewCollectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        self.previewCollectionView?.selectedPhotoIndex = index
    }
    
    public func reloadPhotos() {
        self.pagedView.reloadPhotos()
        self.previewCollectionView?.reloadData()
        self.updateLabelView()
    }
    
    func numberOfPhotos() -> Int {
        return self.dataSource?.numberOfPhotos(self) ?? 0
    }
}

//MARK: - PhotoBrowserViewControllerDelegate

extension PhotoBrowserView: PhotoBrowserInfinitePagedDataSource, PhotoBrowserInfinitePagedDelegate {
    func photoBrowserInfinitePhotoViewed(at index: Int) {
        self.delegate?.photoBrowser(self, photoViewedAtIndex: index, mode: .inline)
        self.previewCollectionView?.selectedPhotoIndex = index
        self.updateLabelView()
    }
    
    func photoBrowserInfinitePhotoTapped(at index: Int) {
        self.delegate?.photoBrowser(self, photoTappedAtIndex: index, mode: .inline)
    }
    
    func photoBrowserInfiniteLoadPhoto(_ index: Int, forImageView imageView: UIImageView, completion: @escaping (UIImage?) -> ()) {
        self.dataSource?.photoBrowser(self, photoAtIndex: index, forImageView: imageView, completion: completion)
    }
}

extension PhotoBrowserView: PhotoBrowserPreviewDataSource, PhotoBrowserPreviewDelegate {
    func photoBrowserPreviewLoadThumbnail(_ index: Int, forImageView imageView: UIImageView, completion: @escaping (UIImage?) -> ()) {
        self.dataSource?.photoBrowser(self, thumbnailAtIndex: index, forImageView: imageView, completion: completion)
    }
    
    func photoBrowserPreviewThumbnailTapped(at index: Int) {
        self.delegate?.photoBrowser(self, thumbnailTappedAtIndex: index, mode: .inline)
        self.pagedView.reloadPhotos(at: index)
    }
    
    func photoBrowserPreviewThumbnailViewed(at index: Int) {
        self.delegate?.photoBrowser(self, thumbnailViewedAtIndex: index, mode: .inline)
    }
}

extension PhotoBrowserView: PhotoBrowserFullscreenDataSource, PhotoBrowserFullscreenDelegate {
    func photoBrowserFullscreenWillDismiss(selectedIndex: Int) {
        self.pagedView.reloadPhotos(at: selectedIndex)
        self.previewCollectionView?.selectedPhotoIndex = selectedIndex
    }
    
    func photoBrowserFullscreenLoadPhoto(_ index: Int, forImageView imageView: UIImageView, completion: @escaping (UIImage?) -> ()) {
        self.dataSource?.photoBrowser(self, photoAtIndex: index, forImageView: imageView, completion: completion)
    }
    
    func photoBrowserFullscreenLoadThumbanil(_ index: Int, forImageView imageView: UIImageView, completion: @escaping (UIImage?) -> ()) {
        self.dataSource?.photoBrowser(self, thumbnailAtIndex: index, forImageView: imageView, completion: completion)
    }
    
    func photoBrowserFullscreenDidDismiss(selectedIndex: Int) {
        self.delegate?.photoBrowserFullscreenWasDismissed()
    }
    
    func photoBrowserFullscreenThumbnailTapped(_ index: Int) {
        self.delegate?.photoBrowser(self, thumbnailTappedAtIndex: index, mode: .fullscreen)
    }
    
    func photoBrowserFullscreenThumbnailViewed(_ index: Int) {
        self.delegate?.photoBrowser(self, thumbnailViewedAtIndex: index, mode: .fullscreen)
    }
    
    func photoBrowserFullscreenPhotoTapped(_ index: Int) {
        self.delegate?.photoBrowser(self, photoTappedAtIndex: index, mode: .fullscreen)
    }
    
    func photoBrowserFullscreenPhotoViewed(_ index: Int) {
        self.delegate?.photoBrowser(self, photoViewedAtIndex: index, mode: .fullscreen)
        self.updateLabelView()
    }
}

// MARK: - Interface builder preview code

extension PhotoBrowserView {
    public override func prepareForInterfaceBuilder() {
        self.layer.borderColor = UIColor(white: 0.8, alpha: 0.9).cgColor
        self.layer.borderWidth = 1
        
        var frame = self.bounds
        frame.origin.x += 1
        frame.origin.y += 1
        frame.size.width -= 2
        frame.size.height -= 2
        let label = UILabel(frame: frame)
        label.text = "JanePhotoBrowser"
        label.textColor = UIColor.white
        
        if #available(iOS 8.2, *) {
            label.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.bold)
        } else {
            label.font = UIFont(name: "HelveticaNeue-Medium", size: 13)
        }
        
        label.backgroundColor = UIColor(red: 0.718, green: 0.8, blue: 0.898, alpha: 0.9)
        
        label.layer.borderColor = UIColor.white.cgColor
        label.layer.borderWidth = 1
        label.textAlignment = .center
        
        self.addSubview(label)
    }
    
}
