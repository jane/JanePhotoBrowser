//
//  PhotoBrowserView.swift
//  JanePhotoBrowser
//
//  Copyright © 2016 Jane. All rights reserved.
//

import UIKit

class PhotoBrowserView:UIView {
    //MARK: - Private Variables
    private let collectionView:UICollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: PhotoBrowserView.layout())
    private var imageLabel:UILabel = UILabel()
    
    //MARK: - Variables
    weak var dataSource:PhotoBrowserDataSource? {
        didSet {
            self.collectionView.reloadData()
            self.updateLabelView()
        }
    }
    weak var delegate:PhotoBrowserDelegate?
    var viewIsAnimating:Bool = false
    
    //MARK: - IBInspectable
    @IBInspectable var canZoom:Bool = false {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    @IBInspectable var labelFont:UIFont = UIFont.systemFontOfSize(10) {
        didSet {
            self.imageLabel.font = labelFont
        }
    }
    
    //MARK: - UIView
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupPhotoView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupPhotoView()
    }
    
    init() {
        super.init(frame:CGRect.zero)
        self.setupPhotoView()
    }
    
    override func layoutSubviews() {
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
    
    private func setupPhotoView() {
        let numberView:UIView = UIView()
        
        self.collectionView.backgroundColor = self.backgroundColor
        self.collectionView.registerClass(PhotoBrowserCell.self, forCellWithReuseIdentifier: "PhotoCell")
        self.collectionView.pagingEnabled = true
        
        numberView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.imageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(self.collectionView)
        self.addSubview(numberView)
        
        //Setup CollectionView datasource and delegate
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        //Setup collectionview layout constraints
        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: [], metrics: nil, views: ["view":self.collectionView])
        let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: [], metrics: nil, views: ["view":self.collectionView])
        self.addConstraints(vConstraints)
        self.addConstraints(hConstraints)
        
        //Setup Number Label
        numberView.backgroundColor = UIColor(white: 0.8, alpha: 0.8)
        let vNumberViewConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[view(30)]-10-|", options: [], metrics: nil, views: ["view":numberView])
        let hNumberViewConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:[view(70)]-10-|", options: [], metrics: nil, views: ["view":numberView])
        self.addConstraints(vNumberViewConstraints)
        self.addConstraints(hNumberViewConstraints)
        
        numberView.addSubview(self.imageLabel)
        self.imageLabel.font = self.labelFont
        self.updateLabelView()
        numberView.addConstraint(NSLayoutConstraint(item: self.imageLabel, attribute: .CenterX, relatedBy: .Equal, toItem: numberView, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        numberView.addConstraint(NSLayoutConstraint(item: self.imageLabel, attribute: .CenterY, relatedBy: .Equal, toItem: numberView, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        
        //Setup Close Button
        
    }
    
    //MARK: - PhotoBrowser Methods
    func scrollToPhoto(atIndex index:Int, animated:Bool) {
        let indexPath:NSIndexPath = NSIndexPath(forRow: index, inSection: 0)
        self.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: [.CenteredVertically, .CenteredHorizontally], animated: animated)
        self.updateLabelView()
    }
    
    func closeTapped(sender:UIButton) {
        guard let photoDelegate = self.delegate else { return }
        photoDelegate.closeButtonTapped()
    }
    
    func visibleImageView() -> UIImageView? {
        guard let cell = self.collectionView.visibleCells().first as? PhotoBrowserCell else { return nil }
        return cell.imageView
    }
    func visibleIndexPath() -> NSIndexPath? {
        let indexPaths = self.collectionView.indexPathsForVisibleItems()
        print(indexPaths)
        return indexPaths.first
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.updateLabelView()
    }
}

//MARK: - UICollectionViewDelegate/DataSource/Layouts
extension PhotoBrowserView:UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource?.numberOfPhotos(self) ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:PhotoBrowserCell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoBrowserCell
        
        if let image = self.dataSource?.photoBrowser(self, photoAtIndex: indexPath.row) {
            cell.imageView.image = image
            cell.canZoom = self.canZoom
        }
        
        cell.tapped = {
            self.delegate?.photoBrowser(self, photoTappedAtIndex: indexPath)
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return self.frame.size
    }
}
