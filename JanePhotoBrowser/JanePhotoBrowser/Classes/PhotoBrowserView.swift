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
    
    //MARK: - Variables
    weak var dataSource:PhotoBrowserDataSource?
    weak var delegate:PhotoBrowserDelegate?
    var viewIsAnimating:Bool = false
    
    //MARK: - IBInspectable
    @IBInspectable var canZoom:Bool = false {
        didSet {
            self.collectionView.reloadData()
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
    
    //MARK: - Private PhotoBrowser Methods
    private class func layout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        
        return layout
    }
    
    private func setupPhotoView() {
        self.collectionView.backgroundColor = self.backgroundColor
        self.collectionView.registerClass(PhotoBrowserCell.self, forCellWithReuseIdentifier: "PhotoCell")
        self.collectionView.pagingEnabled = true
        
        self.addSubview(self.collectionView)
        
        //Setup CollectionView datasource and delegate
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        //Setup collectionview layout constraints
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: [], metrics: nil, views: ["view":self.collectionView])
        let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: [], metrics: nil, views: ["view":self.collectionView])
        self.addConstraints(vConstraints)
        self.addConstraints(hConstraints)
        
        //Setup Number Label
        let numberView:UIView = UIView()
        
        //Setup Close Button
        
    }
    
    //MARK: - PhotoBrowser Methods
    func scrollToPhoto(atIndex index:Int, animated:Bool) {
        let indexPath:NSIndexPath = NSIndexPath(forRow: index, inSection: 0)
        self.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: [.CenteredVertically, .CenteredHorizontally], animated: animated)
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
        return self.collectionView.indexPathsForVisibleItems().first
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
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
