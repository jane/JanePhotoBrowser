//
//  PhotoBrowserCell.swift
//  JanePhotoBrowser
//
//  Copyright © 2016 Jane. All rights reserved.
//

import UIKit

public protocol PhotoBrowserViewCell {
    var imageView:UIImageView { get set }
}

class PhotoBrowserCell:UICollectionViewCell, PhotoBrowserViewCell {
    //MARK: - Private Variables
    fileprivate var scrollView:UIScrollView = UIScrollView()
    
    //MARK: - Variables
    var imageView:UIImageView = UIImageView()
    var tapped:(()->())? = nil
    var canZoom:Bool = false {
        didSet {
            self.scrollView.maximumZoomScale = self.canZoom ? 4.0 : 1.0
        }
    }
    
    fileprivate weak var widthConstraint: NSLayoutConstraint?
    fileprivate weak var heightConstraint: NSLayoutConstraint?
    
    //MARK: - UICollectionViewCell
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupImageView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupImageView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.scrollView.zoomScale = 1.0
    }
    
    func setImageViewSize(_ size: CGSize) {
        self.widthConstraint?.constant = size.width
        self.heightConstraint?.constant = size.height
    }
    
    //MARK: - PhotoBrowserCell Private Methods
    fileprivate func setupImageView() {
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = self.canZoom ? 4.0 : 1.0
        
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.delegate = self
        
        self.imageView.contentMode = .scaleAspectFit
        self.addSubview(self.scrollView)
        self.scrollView.addSubview(self.imageView)
        
        //Add ImageView constraints
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        let vImageConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: ["view":self.imageView])
        let hImageConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: ["view":self.imageView])
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: ["view":self.scrollView])
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: ["view":self.scrollView])
        
        self.addConstraints(vImageConstraints)
        self.addConstraints(hImageConstraints)
        self.addConstraints(vConstraints)
        self.addConstraints(hConstraints)
        
        let widthConstraint = NSLayoutConstraint(item: self.imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: self.frame.size.width)
        let heightConstraint = NSLayoutConstraint(item: self.imageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: self.frame.size.height)
        self.widthConstraint = widthConstraint
        self.heightConstraint = heightConstraint
        
        self.addConstraints([widthConstraint, heightConstraint])
        
        //Add Tap Gesture to capture cell tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.scrollView.addGestureRecognizer(tap)
    }
    
    //MARK: - PhotoBrowserCell Methods
    func handleTap(_ gesture:UITapGestureRecognizer) {
        guard let callback = self.tapped else { return }
        callback()
    }
    
}

//MARK: - UIScrollViewDelegate
extension PhotoBrowserCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    
}
