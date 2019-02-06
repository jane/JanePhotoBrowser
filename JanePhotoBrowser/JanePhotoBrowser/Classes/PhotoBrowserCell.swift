//
//  PhotoBrowserCell.swift
//  JanePhotoBrowser
//
//  Copyright © 2016 Jane. All rights reserved.
//

import UIKit

public class PhotoBrowserCell:UICollectionViewCell {
    //MARK: - Private Variables
    fileprivate var scrollView:UIScrollView = UIScrollView()
    
    //MARK: - Variables
    public var imageView:UIImageView = UIImageView()
    var tapped:(()->())? = nil
    var canZoom:Bool = false {
        didSet {
            self.scrollView.maximumZoomScale = self.canZoom ? 4.0 : 1.0
        }
    }
    
    public var imageScaleToFit = false {
        didSet {
            self.imageView.clipsToBounds = true
            self.imageView.contentMode = .scaleAspectFill
        }
    }
    
    public var cellSelected = false {
        didSet {
            self.configureImageViewAlpha()
        }
    }
    
    //MARK: - UICollectionViewCell
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupImageView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupImageView()
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        self.scrollView.zoomScale = 1.0
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
        let vImageConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]", options: [], metrics: nil, views: ["view":self.imageView])
        let hImageConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: ["view":self.imageView])
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: ["view":self.scrollView])
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: ["view":self.scrollView])
        
        self.addConstraints(vImageConstraints)
        self.addConstraints(hImageConstraints)
        self.addConstraints(vConstraints)
        self.addConstraints(hConstraints)
        
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: self.imageView, attribute: .height, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: self.imageView, attribute: .width, multiplier: 1, constant: 0))
        
        //Add Tap Gesture to capture cell tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.scrollView.addGestureRecognizer(tap)
    }
    
    //MARK: - PhotoBrowserCell Methods
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let callback = self.tapped else { return }
        callback()
    }
    
    private func configureImageViewAlpha() {
        if self.cellSelected {
            self.imageView.alpha = 0.3
        } else {
            self.imageView.alpha = 1
        }
    }
}

//MARK: - UIScrollViewDelegate
extension PhotoBrowserCell: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
