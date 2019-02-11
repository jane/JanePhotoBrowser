//
//  PhotoBrowserView.swift
//  JanePhotoBrowser
//
//  Copyright © 2016 Jane. All rights reserved.
//

import UIKit

@IBDesignable
public class PhotoBrowserView: UIView {
    
    //MARK: - Private Variables
    
    fileprivate var largeImagesCollectionView: UICollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: PhotoBrowserView.largeImagesLayout())
    fileprivate var smallImagesCollectionView: UICollectionView?
    fileprivate var imageLabel: UILabel = UILabel()
    fileprivate var closeButtonWrapper: UIView = UIView()
    fileprivate let closeButton: UIButton = UIButton()
    fileprivate var numberView:UIView = UIView()
    
    fileprivate var numberViewRightConstraint: NSLayoutConstraint?
    fileprivate var defaultNumberViewRightOffset: CGFloat = 16
    public var numberViewRightOffset: CGFloat {
        get {
            return self.numberViewRightConstraint?.constant ?? self.defaultNumberViewRightOffset
        }
        set {
            self.defaultNumberViewRightOffset = newValue
            self.numberViewRightConstraint?.constant = newValue
        }
    }
    public var visibleRow: Int = -1
    
    /// Set this to `true` if you want the preview to show up while not in full screen mode
    public var showPreview: Bool = false {
        didSet {
            if self.showPreview {
                self.smallImagesCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: PhotoBrowserView.smallImagesLayout())
            } else {
                self.smallImagesCollectionView = nil
            }
            self.setNeedsDisplay()
            self.layoutSubviews()
            self.setupPhotoView()
        }
    }
    
    /// Set this to `true` if you want the preview to show up while in full screen mode
    public var showFullScreenPreview: Bool = false
    
    fileprivate var numberViewBottomConstraint: NSLayoutConstraint?
    fileprivate var defaultNumberViewBottomOffset: CGFloat = 16
    public var numberViewBottomOffset: CGFloat {
        get {
            return self.numberViewBottomConstraint?.constant ?? self.defaultNumberViewBottomOffset
        }
        set {
            self.defaultNumberViewBottomOffset = newValue
            self.numberViewBottomConstraint?.constant = newValue
        }
    }
    
    //MARK: - Variables
    
    public weak var dataSource: PhotoBrowserDataSource? {
        didSet {
            self.largeImagesCollectionView.reloadData()
            self.smallImagesCollectionView?.reloadData()
            self.updateLabelView()
        }
    }
    public weak var delegate: PhotoBrowserDelegate? {
        didSet {
            self.updateLabelView()
        }
    }
    var viewIsAnimating: Bool = false {
        didSet {
            if self.viewIsAnimating {
                self.numberView.alpha = 0
            } else {
                UIView.animate(withDuration: 0.1) { [weak self] in
                    self?.numberView.alpha = 1
                }
            }
        }
    }
    var currentVisibleIndexPath: IndexPath?
    
    //MARK: - IBInspectable
    
    @IBInspectable public var canZoom: Bool = false {
        didSet {
            self.largeImagesCollectionView.reloadData()
            self.smallImagesCollectionView?.reloadData()
        }
    }
    
    @IBInspectable public var labelFont: UIFont = UIFont.systemFont(ofSize: 12) {
        didSet {
            self.imageLabel.font = labelFont
        }
    }
    
    @IBInspectable public var shouldDisplayCloseButton:Bool = false {
        didSet {
            self.closeButtonWrapper.isHidden = !shouldDisplayCloseButton
        }
    }
    
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
        if let superview = self.imageLabel.superview {
            self.bringSubviewToFront(superview)
        }
    }
    
    //MARK: - UIView
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.setupPhotoView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupPhotoView()
    }
    
    public init() {
        super.init(frame:CGRect.zero)
        self.setupPhotoView()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        self.updateLabelView()
        
        let largeImagesLayout = PhotoBrowserView.largeImagesLayout()
        let smallImagesLayout = PhotoBrowserView.smallImagesLayout()
        
        largeImagesLayout.itemSize = self.largeImagesCollectionView.bounds.size
        self.largeImagesCollectionView.collectionViewLayout = largeImagesLayout
        
        if let smallCollectionView = self.smallImagesCollectionView {
            let smallImageWidth = smallCollectionView.bounds.height - 4
            smallImagesLayout.itemSize = CGSize(width: smallImageWidth, height: smallImageWidth)
            smallCollectionView.collectionViewLayout = smallImagesLayout
        }
        if let visibleIndexPath = self.currentVisibleIndexPath ?? self.visibleIndexPath() {
            self.scrollToPhoto(atIndex: visibleIndexPath.item, animated: false)
        }
    }
    
    //MARK: - Private PhotoBrowser Methods
    
    fileprivate class func largeImagesLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        
        return layout
    }
    
    fileprivate class func smallImagesLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 4
        
        return layout
    }
    
    func updateLabelView(with index: Int? = nil) {
        let hasWidth = self.largeImagesCollectionView.frame.size.width > 0
        var row = hasWidth ? Int(self.largeImagesCollectionView.contentOffset.x / self.largeImagesCollectionView.frame.size.width) + 1 : 1
        
        let max = self.dataSource?.numberOfPhotos(self) ?? 0
        
        if row > max {
            row = max
        }
        
        if self.visibleRow != row {
            self.delegate?.photoBrowser(self, photoViewedAtIndex: IndexPath(item: row - 1, section: 0))
            self.visibleRow = row
        }
        
        self.imageLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        self.imageLabel.text = "\(index ?? row) of \(max)"
        self.imageLabel.accessibilityIdentifier = "JanePhotoBrowser-imageCountLabel"
        self.setSmallCellSelected(at: row - 1)
    }
    
    @discardableResult
    fileprivate func addVisualConstraints(_ vertical:String, horizontal:String, view:UIView) -> (vertical: [NSLayoutConstraint], horizontal: [NSLayoutConstraint]) {
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: vertical, options: [], metrics: nil, views: ["view":view])
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: horizontal, options: [], metrics: nil, views: ["view":view])
        self.addConstraints(verticalConstraints)
        self.addConstraints(horizontalConstraints)
        
        return (vertical: verticalConstraints, horizontal: horizontalConstraints)
    }
    
    fileprivate func setupCloseButton() {
        self.closeButton.backgroundColor = UIColor.clear
        self.closeButton.setImage(PhotoBrowserStyleKit.imageOfXIcon(fillColor: UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)), for: .normal)
        self.closeButton.addTarget(self, action: #selector(self.closeTapped(_:)), for: .touchUpInside)
        self.closeButtonWrapper.layer.cornerRadius = 3
        self.closeButtonWrapper.layer.masksToBounds = true
        
        if #available(iOS 8.2, *) {
            self.closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 26, weight: UIFont.Weight.thin)
        } else {
            self.closeButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Thin", size: 30)
        }
        
        self.addVisualConstraints("V:|-[view(35)]", horizontal: "H:[view(35)]-16-|", view: self.closeButtonWrapper)
    }
    
    fileprivate func setupPhotoView() {
        self.numberView = UIView()
        self.numberView.layer.cornerRadius = 3
        self.numberView.layer.masksToBounds = true
        
        let closeBlurEffect = UIBlurEffect(style: UIBlurEffect.Style.extraLight)
        let closeBlurEffectView = UIVisualEffectView(effect: closeBlurEffect)
        //always fill the view
        closeBlurEffectView.frame = self.closeButtonWrapper.bounds
        closeBlurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.closeButtonWrapper.addSubview(closeBlurEffectView)
        self.closeButtonWrapper.backgroundColor = UIColor.clear
        self.closeButtonWrapper.addSubview(self.closeButton)
        
        self.closeButtonWrapper.isHidden = !self.shouldDisplayCloseButton
        
        self.largeImagesCollectionView.backgroundColor = self.backgroundColor
        self.largeImagesCollectionView.register(PhotoBrowserCell.self, forCellWithReuseIdentifier: "PhotoCell")
        self.largeImagesCollectionView.isPagingEnabled = true
        self.smallImagesCollectionView?.backgroundColor = self.backgroundColor
        self.smallImagesCollectionView?.register(PhotoBrowserCell.self, forCellWithReuseIdentifier: "PhotoCell")
        self.smallImagesCollectionView?.isPagingEnabled = false
        
        self.numberView.translatesAutoresizingMaskIntoConstraints = false
        self.largeImagesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        self.smallImagesCollectionView?.translatesAutoresizingMaskIntoConstraints = false
        self.imageLabel.translatesAutoresizingMaskIntoConstraints = false
        self.closeButton.translatesAutoresizingMaskIntoConstraints = false
        self.closeButtonWrapper.translatesAutoresizingMaskIntoConstraints = false
        
        //Add all the subviews before applying layout constraints
        self.addSubview(self.largeImagesCollectionView)
        if let smallCollectionView = self.smallImagesCollectionView {
            self.addSubview(smallCollectionView)
        }
        self.addSubview(numberView)
        self.addSubview(self.closeButtonWrapper)
        
        //Setup collectionview layout constraints
        
        let largeImagesLeadingConstraint = NSLayoutConstraint(item: self.largeImagesCollectionView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
        let largeImagesTopConstraint = NSLayoutConstraint(item: self.largeImagesCollectionView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let largeImagesTrailingConstraint = NSLayoutConstraint(item: self.largeImagesCollectionView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
        if let smallCollectionView = self.smallImagesCollectionView {
            let smallImagesHeightConstraint = NSLayoutConstraint(item: smallCollectionView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50)
            let smallImagesLeadingConstraint = NSLayoutConstraint(item: smallCollectionView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
            let smallImagesBottomConstraint = NSLayoutConstraint(item: smallCollectionView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
            let smallImagesTrailingConstraint = NSLayoutConstraint(item: smallCollectionView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
            let largeImagesBottomConstraint = NSLayoutConstraint(item: self.largeImagesCollectionView, attribute: .bottom, relatedBy: .equal, toItem: smallCollectionView, attribute: .top, multiplier: 1, constant: 8)
            self.addConstraints([largeImagesLeadingConstraint, largeImagesTopConstraint, largeImagesTrailingConstraint, smallImagesHeightConstraint, smallImagesLeadingConstraint, smallImagesBottomConstraint, smallImagesTrailingConstraint, largeImagesBottomConstraint])
        } else {
            let largeImagesBottomConstraint = NSLayoutConstraint(item: self.largeImagesCollectionView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 8)
            self.addConstraints([largeImagesLeadingConstraint, largeImagesTopConstraint, largeImagesTrailingConstraint, largeImagesBottomConstraint])
        }
        
        self.addVisualConstraints("V:|[view]|", horizontal: "H:|[view]|", view: self.closeButton)
        
        //Setup CollectionView datasource and delegate
        self.largeImagesCollectionView.dataSource = self
        self.largeImagesCollectionView.delegate = self
        self.smallImagesCollectionView?.dataSource = self
        self.smallImagesCollectionView?.delegate = self
        
        //Setup Number Label
        self.numberView.backgroundColor = UIColor.clear // UIColor(white: 1.0, alpha: 0.8)
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        //always fill the view
        blurEffectView.frame = self.numberView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.numberView.addSubview(blurEffectView)
        
        let previewCollectionViewOffset:CGFloat = self.showPreview ? 30 : 0
        let numberViewConstraints = self.addVisualConstraints("V:[view(30)]-\(self.numberViewBottomOffset + previewCollectionViewOffset)-|", horizontal: "H:[view(70)]-\(self.numberViewRightOffset - previewCollectionViewOffset)-|", view: numberView)
        
        self.numberViewRightConstraint = numberViewConstraints.horizontal.first
        self.numberViewBottomConstraint = numberViewConstraints.vertical.first
        
        self.numberView.addSubview(self.imageLabel)
        self.imageLabel.font = self.labelFont
        self.updateLabelView()
        self.numberView.addConstraint(NSLayoutConstraint(item: self.imageLabel, attribute: .centerX, relatedBy: .equal, toItem: numberView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        self.numberView.addConstraint(NSLayoutConstraint(item: self.imageLabel, attribute: .centerY, relatedBy: .equal, toItem: numberView, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        
        //Setup Close Button
        self.setupCloseButton()
    }
    
    //MARK: - PhotoBrowser Methods
    
    public func scrollToPhoto(atIndex index:Int, animated:Bool) {
        let indexPath:IndexPath = IndexPath(row: index, section: 0)
        guard indexPath.row < self.largeImagesCollectionView.numberOfItems(inSection: 0) && indexPath.row >= 0 else { self.reloadPhotos(); return }
        self.largeImagesCollectionView.scrollToItem(at: indexPath, at: [.centeredVertically, .centeredHorizontally], animated: animated)
        self.smallImagesCollectionView?.scrollToItem(at: indexPath, at: [.centeredVertically, .centeredHorizontally], animated: animated)
        self.currentVisibleIndexPath = indexPath
        self.delegate?.photoBrowser(self, photoViewedAtIndex: indexPath)
        self.updateLabelView(with: index + 1)
        self.setSmallCellSelected(at: index)
    }
    
    @objc public func closeTapped(_ sender:UIButton) {
        self.delegate?.photoBrowserCloseButtonTapped()
    }
    
    public func visibleImageView() -> UIImageView? {
        guard let cell = self.largeImagesCollectionView.visibleCells.first as? PhotoBrowserCell else { return nil }
        return cell.imageView
    }
    
    public func visibleIndexPath() -> IndexPath? {
        let indexPaths = self.largeImagesCollectionView.indexPathsForVisibleItems
        return indexPaths.first
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.currentVisibleIndexPath = self.visibleIndexPath()
        self.updateLabelView()
    }
    
    public func reloadPhotos() {
        self.largeImagesCollectionView.reloadData()
        self.smallImagesCollectionView?.reloadData()
        self.updateLabelView()
    }
    
    public func reloadImage(atIndexPath indexPath:IndexPath) {
        self.largeImagesCollectionView.reloadItems(at: [indexPath])
        self.smallImagesCollectionView?.reloadItems(at: [indexPath])
    }
    
    fileprivate func setSmallCellSelected(at index: Int) {
        guard let cell = self.smallImagesCollectionView?.cellForItem(at: IndexPath(row: index, section: 0)) as? PhotoBrowserCell,
            let cells = self.smallImagesCollectionView?.visibleCells as? [PhotoBrowserCell],
            index >= 0  else { return }
        for cell in cells where cell.cellSelected == true {
            cell.cellSelected = false
        }
        cell.cellSelected = true
    }
}

//MARK: - UICollectionViewDelegate/DataSource/Layouts

extension PhotoBrowserView:UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource?.numberOfPhotos(self) ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:PhotoBrowserCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoBrowserCell
        
        cell.imageView.image = nil
        cell.imageView.tag = indexPath.item
        self.dataSource?.photoBrowser(self, photoAtIndex: indexPath.row, forCell:cell) { [weak cell] image in
            guard let cell = cell, cell.imageView.tag == indexPath.item else { return }
            cell.imageView.image = image
        }
        if collectionView === self.largeImagesCollectionView {
            cell.canZoom = self.canZoom
            
            cell.tapped = { [weak self] in
                guard let self = self else { return }
                self.delegate?.photoBrowser(self, photoTappedAtIndex: indexPath)
            }
        } else if collectionView === self.smallImagesCollectionView {
            cell.tapped = { [weak self] in
                guard let self = self else { return }
                self.scrollToPhoto(atIndex: indexPath.row, animated: true)
                self.delegate?.photoBrowser(self, photoViewedAtIndex: indexPath)
                self.setSmallCellSelected(at: indexPath.row)
            }
            cell.imageScaleToFit = true
            if self.visibleIndexPath() == nil, indexPath.row == 0 { cell.cellSelected = true }
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard collectionView === self.smallImagesCollectionView,
            let photoCell = cell as? PhotoBrowserCell,
            indexPath == self.currentVisibleIndexPath else { return }
        photoCell.cellSelected = true
    }
}

//MARK: - PhotoBrowserViewControllerDelegate

extension PhotoBrowserView: PhotoBrowserViewControllerDelegate {
    public func photoBrowser(_ photoBrowser: PhotoBrowserViewController, photoViewedAtIndex indexPath: IndexPath) {
        self.delegate?.photoBrowser(self, photoViewedAtIndex: indexPath)
        self.scrollToPhoto(atIndex: indexPath.item, animated: false)
    }
}
