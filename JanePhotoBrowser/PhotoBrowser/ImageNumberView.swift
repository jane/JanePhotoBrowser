//
//  ImageNumberView.swift
//  PhotoBrowser
//
//  Created by Gordon Tucker on 8/2/19.
//  Copyright © 2019 Jane. All rights reserved.
//

import UIKit

public class ImageNumberView: UIView {
    public var blurView: UIVisualEffectView!
    public var label = UILabel()
    
    public var font: UIFont = UIFont.systemFont(ofSize: 12) {
        didSet {
            self.label.font = self.font
        }
    }
    
    public var text: String {
        get {
            return self.label.text ?? ""
        }
        set {
            self.label.text = newValue
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private func setup() {
        self.layer.cornerRadius = 4
        self.layer.masksToBounds = true
        self.backgroundColor = .clear
        
        // Add a blur view so we get a nice effect behind the number count
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.extraLight))
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.blurView = blurView
        self.addSubview(blurView) {
            $0.edges.pinToSuperview()
        }
        
        blurView.contentView.addSubview(self.label) {
            $0.edges.pinToSuperview(insets: UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12), relation: .equal)
        }
        self.label.textColor = UIColor(red: 0.07, green: 0.07, blue: 0.07, alpha: 1)
        self.label.isAccessibilityElement = false
        self.label.font = self.font
        self.label.minimumScaleFactor = 0.5
        self.label.adjustsFontSizeToFitWidth = true
    }
}
