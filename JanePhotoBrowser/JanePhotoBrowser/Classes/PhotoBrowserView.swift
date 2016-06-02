//
//  PhotoBrowserView.swift
//  JanePhotoBrowser
//
//  Copyright © 2016 Jane. All rights reserved.
//

import UIKit

public class PhotoBrowserView:UIView {
    //MARK: - Private Variables
    private let collectionView:UICollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: PhotoBrowserView.layout())
    private var imageLabel:UILabel = UILabel()
    private let closeButton:UIButton = UIButton()
    
    //MARK: - Variables
    public weak var dataSource:PhotoBrowserDataSource? {
        didSet {
            self.collectionView.reloadData()
            self.updateLabelView()
        }
    }
    public weak var delegate:PhotoBrowserDelegate?
    var viewIsAnimating:Bool = false
    
    //MARK: - IBInspectable
    @IBInspectable public var canZoom:Bool = false {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    @IBInspectable public var labelFont:UIFont = UIFont.systemFontOfSize(10) {
        didSet {
            self.imageLabel.font = labelFont
        }
    }
    
    @IBInspectable public var shouldDisplayCloseButton:Bool = false {
        didSet {
            self.closeButton.hidden = !shouldDisplayCloseButton
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
    }
    
    //MARK: - Private PhotoBrowser Methods
    private class func layout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        
        return layout
    }
    
    private func updateLabelView() {
        let hasWidth = self.collectionView.frame.size.width > 0
        let row = hasWidth ? Int(self.collectionView.contentOffset.x / self.collectionView.frame.size.width) + 1 : 1
        
        self.imageLabel.text = "\(row) of \(self.dataSource?.numberOfPhotos(self) ?? 0)"
    }
    
    private func addVisualConstraints(vertical:String, horizontal:String, view:UIView) {
        let veritcalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(vertical, options: [], metrics: nil, views: ["view":view])
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(horizontal, options: [], metrics: nil, views: ["view":view])
        self.addConstraints(veritcalConstraints)
        self.addConstraints(horizontalConstraints)
    }
    
    private func setupCloseButton() {
        self.closeButton.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
        self.closeButton.setImage(PhotoBrowserStyleKit.imageOfXIcon(fillColor: UIColor.blackColor()), forState: .Normal)
        self.closeButton.addTarget(self, action: #selector(self.closeTapped(_:)), forControlEvents: .TouchUpInside)
        self.closeButton.layer.cornerRadius = 5
        self.closeButton.layer.masksToBounds = true
        
        if #available(iOS 8.2, *) {
            self.closeButton.titleLabel?.font = UIFont.systemFontOfSize(26, weight: UIFontWeightThin)
        } else {
            self.closeButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Thin", size: 30)
        }
        
        self.addVisualConstraints("V:|-30-[view(35)]", horizontal: "H:[view(35)]-20-|", view: self.closeButton)
    }
    
    private func setupPhotoView() {
        let numberView:UIView = UIView()
        numberView.layer.cornerRadius = 5
        numberView.layer.masksToBounds = true
        
        self.closeButton.hidden = !self.shouldDisplayCloseButton
        
        self.collectionView.backgroundColor = self.backgroundColor
        self.collectionView.registerClass(PhotoBrowserCell.self, forCellWithReuseIdentifier: "PhotoCell")
        self.collectionView.pagingEnabled = true
        
        numberView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.imageLabel.translatesAutoresizingMaskIntoConstraints = false
        self.closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        //Add all the subviews before applying layout constraints
        self.addSubview(self.collectionView)
        self.addSubview(numberView)
        self.addSubview(self.closeButton)
        
        //Setup CollectionView datasource and delegate
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        //Setup collectionview layout constraints
        self.addVisualConstraints("V:|[view]|", horizontal: "H:|[view]|", view: self.collectionView)
        
        //Setup Number Label
        numberView.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
        self.addVisualConstraints("V:[view(30)]-10-|", horizontal: "H:[view(70)]-10-|", view: numberView)
        
        numberView.addSubview(self.imageLabel)
        self.imageLabel.font = self.labelFont
        self.updateLabelView()
        numberView.addConstraint(NSLayoutConstraint(item: self.imageLabel, attribute: .CenterX, relatedBy: .Equal, toItem: numberView, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        numberView.addConstraint(NSLayoutConstraint(item: self.imageLabel, attribute: .CenterY, relatedBy: .Equal, toItem: numberView, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        
        //Setup Close Button
        self.setupCloseButton()
    }
    
    //MARK: - PhotoBrowser Methods
    public func scrollToPhoto(atIndex index:Int, animated:Bool) {
        let indexPath:NSIndexPath = NSIndexPath(forRow: index, inSection: 0)
        self.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: [.CenteredVertically, .CenteredHorizontally], animated: animated)
        self.updateLabelView()
    }
    
    public func closeTapped(sender:UIButton) {
        guard let photoDelegate = self.delegate else { return }
        photoDelegate.closeButtonTapped()
    }
    
    public func visibleImageView() -> UIImageView? {
        guard let cell = self.collectionView.visibleCells().first as? PhotoBrowserCell else { return nil }
        return cell.imageView
    }
    public func visibleIndexPath() -> NSIndexPath? {
        let indexPaths = self.collectionView.indexPathsForVisibleItems()
        print(indexPaths)
        return indexPaths.first
    }
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.updateLabelView()
    }
    
    public func reloadPhotos() {
        self.collectionView.reloadData()
    }
    
    public func reloadImage(atIndexPath indexPath:NSIndexPath) {
        self.collectionView.reloadItemsAtIndexPaths([indexPath])
    }
}

//MARK: - UICollectionViewDelegate/DataSource/Layouts
extension PhotoBrowserView:UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource?.numberOfPhotos(self) ?? 0
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:PhotoBrowserCell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoBrowserCell
        
        if let image = self.dataSource?.photoBrowser(self, photoAtIndex: indexPath.row, forCell:cell) {
            cell.imageView.image = image
            cell.canZoom = self.canZoom
        }
        
        cell.tapped = {
            self.delegate?.photoBrowser(self, photoTappedAtIndex: indexPath)
        }
        
        return cell
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return self.frame.size
    }
}
