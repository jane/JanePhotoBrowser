//
//  PhotoBrowserCell.swift
//  JanePhotoBrowser
//
//  Copyright © 2016 Jane. All rights reserved.
//

import UIKit

class PhotoBrowserCell:UICollectionViewCell {
    private var scrollView:UIScrollView = UIScrollView()
    var imageView:UIImageView = UIImageView()
    var canZoom:Bool = false {
        didSet {
            self.scrollView.maximumZoomScale = self.canZoom ? 4.0 : 1.0
        }
    }
    var tapped:(()->())? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupImageView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupImageView()
    }
    
    private func setupImageView() {
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = self.canZoom ? 4.0 : 1.0
        
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.delegate = self
        
        self.imageView.contentMode = .ScaleAspectFit
        self.addSubview(self.scrollView)
        self.scrollView.addSubview(self.imageView)
        
        //Add ImageView constraints
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        let width = self.frame.size.width
        let height = self.frame.size.height
        
        let vImageConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[view(\(height))]", options: [], metrics: nil, views: ["view":self.imageView])
        let hImageConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[view(\(width))]|", options: [], metrics: nil, views: ["view":self.imageView])
        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: [], metrics: nil, views: ["view":self.scrollView])
        let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: [], metrics: nil, views: ["view":self.scrollView])
        
        self.addConstraints(vImageConstraints)
        self.addConstraints(hImageConstraints)
        self.addConstraints(vConstraints)
        self.addConstraints(hConstraints)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.scrollView.addGestureRecognizer(tap)
    }
    
    func handleTap(gesture:UITapGestureRecognizer) {
        guard let callback = self.tapped else { return }
        callback()
    }
    
}

extension PhotoBrowserCell: UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
