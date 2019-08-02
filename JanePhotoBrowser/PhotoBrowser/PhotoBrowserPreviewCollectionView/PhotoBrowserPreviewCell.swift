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
    
    var isSelectedPhoto: Bool = false {
        didSet {
            self.imageView.alpha = self.isSelectedPhoto ? 0.3 : 1
            self.contentView.layer.borderWidth = self.isSelectedPhoto ? 1 : 0
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
        self.contentView.layer.borderColor = UIColor(white: 0.07, alpha: 1).cgColor
    }
}
