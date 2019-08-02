//
//  PhotoBrowserPreviewCollectionView.swift
//  PhotoBrowser
//
//  Created by Gordon Tucker on 8/1/19.
//  Copyright © 2019 Jane. All rights reserved.
//

import UIKit

public class PhotoBrowserPreviewCollectionView: UICollectionView {

    weak var photoDataSource: PhotoBrowserPreviewDataSource!
    weak var photoDelegate: PhotoBrowserPreviewDelegate!
    
    var selectedPhotoIndex: Int = 0 {
        didSet {
            guard self.selectedPhotoIndex >= 0, self.selectedPhotoIndex < self.photoDataSource.numberOfPhotos() else {
                self.reloadData()
                return
            }
            let indexPath = IndexPath(item: self.selectedPhotoIndex, section: 0)
            
            self.visibleCells.compactMap({ $0 as? PhotoBrowserPreviewCell }).forEach({ $0.isSelectedPhoto = false })
            if let cell = self.cellForItem(at: indexPath) as? PhotoBrowserPreviewCell {
                cell.isSelectedPhoto = true
            } else {
                self.reloadItems(at: [indexPath])
            }
            
            self.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    init(dataSource: PhotoBrowserPreviewDataSource, delegate: PhotoBrowserPreviewDelegate) {
        super.init(frame: .zero, collectionViewLayout: PhotoBrowserPreviewCollectionView.layout())
        self.photoDataSource = dataSource
        self.photoDelegate = delegate
        self.delegate = self
        self.dataSource = self
        self.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        self.backgroundColor = .clear
        self.showsHorizontalScrollIndicator = false
        self.register(PhotoBrowserPreviewCell.self, forCellWithReuseIdentifier: "photo")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    static func layout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 4
        
        return layout
    }
}

extension PhotoBrowserPreviewCollectionView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photoDataSource.numberOfPhotos()
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photo", for: indexPath) as! PhotoBrowserPreviewCell
        
        cell.imageView.tag = indexPath.item
        cell.imageView.isAccessibilityElement = true
        
        let totalNumberOfImages = self.photoDataSource.numberOfPhotos()
        cell.imageView.accessibilityLabel = "Thumbnail \(indexPath.item + 1) of \(totalNumberOfImages)"
        cell.imageView.accessibilityHint = "Tap to view image \(indexPath.item + 1) of \(totalNumberOfImages)"
        
        self.photoDataSource.photoBrowserPreviewLoadThumbnail(indexPath.item, forImageView: cell.imageView) { [weak cell] image in
            guard let cell = cell, cell.imageView.tag == indexPath.item else { return }
            cell.imageView.image = image
        }
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let photoCell = cell as? PhotoBrowserPreviewCell else { return }
        photoCell.isSelectedPhoto = indexPath.item == self.selectedPhotoIndex
        self.photoDelegate.photoBrowserPreviewThumbnailViewed(at: indexPath.item)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        self.selectedPhotoIndex = indexPath.item
        self.photoDelegate.photoBrowserPreviewThumbnailTapped(at: indexPath.item)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 50)
    }
}
