//
//  PhotoBrowserPreviewCell.swift
//  PhotoBrowser
//
//  Created by Gordon Tucker on 8/1/19.
//  Copyright © 2019 Jane. All rights reserved.
//

import UIKit

class PhotoBrowserPreviewCell: UICollectionViewCell {
    public var imageView:UIImageView = UIImageView()
    
    var isSelectedPhoto: Bool = false
    {
        didSet {
            self.contentView.layer.borderColor = self.isSelectedPhoto ? UIColor.black.cgColor : UIColor.clear.cgColor
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
        self.isSelectedPhoto = false
        self.imageView.image = nil
    }
    
    private func setupImageView() {
        self.imageView.contentMode = .scaleAspectFill
        self.contentView.addSubview(self.imageView) {
            $0.edges.pinToSuperview()
        }
        self.contentView.layer.cornerRadius = 4
        self.contentView.layer.masksToBounds = true
        self.contentView.layer.borderWidth = 2
    }
}
