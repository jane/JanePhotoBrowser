//
//  PhotoBrowserView.swift
//  JanePhotoBrowser
//
//  Copyright © 2016 Jane. All rights reserved.
//

import UIKit

open class PhotoBrowserView:UIView {
    //MARK: - Private Variables
    fileprivate let collectionView:UICollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: PhotoBrowserView.layout())
    fileprivate var imageLabel:UILabel = UILabel()
    fileprivate let closeButton:UIButton = UIButton()
    
    //MARK: - Variables
    open weak var dataSource:PhotoBrowserDataSource? {
        didSet {
            self.collectionView.reloadData()
            self.updateLabelView()
        }
    }
    open weak var delegate:PhotoBrowserDelegate?
    var viewIsAnimating:Bool = false
    
    //MARK: - IBInspectable
    @IBInspectable open var canZoom:Bool = false {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    @IBInspectable open var labelFont:UIFont = UIFont.systemFont(ofSize: 10) {
        didSet {
            self.imageLabel.font = labelFont
        }
    }
    
    @IBInspectable open var shouldDisplayCloseButton:Bool = false {
        didSet {
            self.closeButton.isHidden = !shouldDisplayCloseButton
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
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        self.updateLabelView()
    }
    
    //MARK: - Private PhotoBrowser Methods
    fileprivate class func layout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        
        return layout
    }
    
    fileprivate func updateLabelView() {
        let hasWidth = self.collectionView.frame.size.width > 0
        let row = hasWidth ? Int(self.collectionView.contentOffset.x / self.collectionView.frame.size.width) + 1 : 1
        
        self.imageLabel.text = "\(row) of \(self.dataSource?.numberOfPhotos(self) ?? 0)"
    }
    
    fileprivate func addVisualConstraints(_ vertical:String, horizontal:String, view:UIView) {
        let veritcalConstraints = NSLayoutConstraint.constraints(withVisualFormat: vertical, options: [], metrics: nil, views: ["view":view])
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: horizontal, options: [], metrics: nil, views: ["view":view])
        self.addConstraints(veritcalConstraints)
        self.addConstraints(horizontalConstraints)
    }
    
    fileprivate func setupCloseButton() {
        self.closeButton.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
        self.closeButton.setImage(PhotoBrowserStyleKit.imageOfXIcon(fillColor: UIColor.black), for: .normal)
        self.closeButton.addTarget(self, action: #selector(self.closeTapped(_:)), for: .touchUpInside)
        self.closeButton.layer.cornerRadius = 5
        self.closeButton.layer.masksToBounds = true
        
        if #available(iOS 8.2, *) {
            self.closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 26, weight: UIFontWeightThin)
        } else {
            self.closeButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Thin", size: 30)
        }
        
        self.addVisualConstraints("V:|-30-[view(35)]", horizontal: "H:[view(35)]-20-|", view: self.closeButton)
    }
    
    fileprivate func setupPhotoView() {
        let numberView:UIView = UIView()
        numberView.layer.cornerRadius = 5
        numberView.layer.masksToBounds = true
        
        self.closeButton.isHidden = !self.shouldDisplayCloseButton
        
        self.collectionView.backgroundColor = self.backgroundColor
        self.collectionView.register(PhotoBrowserCell.self, forCellWithReuseIdentifier: "PhotoCell")
        self.collectionView.isPagingEnabled = true
        
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
        numberView.addConstraint(NSLayoutConstraint(item: self.imageLabel, attribute: .centerX, relatedBy: .equal, toItem: numberView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        numberView.addConstraint(NSLayoutConstraint(item: self.imageLabel, attribute: .centerY, relatedBy: .equal, toItem: numberView, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        
        //Setup Close Button
        self.setupCloseButton()
    }
    
    //MARK: - PhotoBrowser Methods
    open func scrollToPhoto(atIndex index:Int, animated:Bool) {
        let indexPath:IndexPath = IndexPath(row: index, section: 0)
        guard indexPath.row < self.collectionView.numberOfItems(inSection: 0) && indexPath.row >= 0 else { self.reloadPhotos(); return }
        self.collectionView.scrollToItem(at: indexPath, at: [.centeredVertically, .centeredHorizontally], animated: animated)
        self.updateLabelView()
    }
    
    open func closeTapped(_ sender:UIButton) {
        guard let photoDelegate = self.delegate else { return }
        photoDelegate.closeButtonTapped()
    }
    
    open func visibleImageView() -> UIImageView? {
        guard let cell = self.collectionView.visibleCells.first as? PhotoBrowserCell else { return nil }
        return cell.imageView
    }
    open func visibleIndexPath() -> IndexPath? {
        let indexPaths = self.collectionView.indexPathsForVisibleItems
        print(indexPaths)
        return indexPaths.first
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.updateLabelView()
    }
    
    open func reloadPhotos() {
        self.collectionView.reloadData()
        self.updateLabelView()
    }
    
    open func reloadImage(atIndexPath indexPath:IndexPath) {
        self.collectionView.reloadItems(at: [indexPath])
    }
}

//MARK: - UICollectionViewDelegate/DataSource/Layouts
extension PhotoBrowserView:UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource?.numberOfPhotos(self) ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:PhotoBrowserCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoBrowserCell
        
        if let image = self.dataSource?.photoBrowser(self, photoAtIndex: indexPath.row, forCell:cell) {
            cell.imageView.image = image
            cell.canZoom = self.canZoom
        }
        
        cell.tapped = {
            self.delegate?.photoBrowser(self, photoTappedAtIndex: indexPath)
        }
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.frame.size
    }
}
