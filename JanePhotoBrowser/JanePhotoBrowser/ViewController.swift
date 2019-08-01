//
//  ViewController.swift
//  JanePhotoBrowser
//
//  Copyright © 2016 Jane. All rights reserved.
//

import UIKit
import PhotoBrowser

class ViewController: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet var photoBrowserView: PhotoBrowserView?
    
    //MARK: - Private Variables
    fileprivate var images:[UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up data source and delegates
        self.photoBrowserView?.dataSource = self
        self.photoBrowserView?.delegate = self
//        self.photoView?.showPreview = true
        
        //Get an array of images
        guard let photo1 = UIImage(named: "photoBrowser1"),
            let photo2 = UIImage(named: "photoBrowser2"),
            let photo3 = UIImage(named: "photoBrowser3"),
            let photo4 = UIImage(named: "photoBrowser4"),
            let photo5 = UIImage(named: "photoBrowser1"),
            let photo6 = UIImage(named: "photoBrowser2"),
            let photo7 = UIImage(named: "photoBrowser3"),
            let photo8 = UIImage(named: "photoBrowser4"),
            let photo9 = UIImage(named: "photoBrowser1"),
            let photo10 = UIImage(named: "photoBrowser2"),
            let photo11 = UIImage(named: "photoBrowser3"),
            let photo12 = UIImage(named: "photoBrowser4"),
            let photo13 = UIImage(named: "photoBrowser1"),
            let photo14 = UIImage(named: "photoBrowser2"),
            let photo15 = UIImage(named: "photoBrowser3"),
            let photo16 = UIImage(named: "photoBrowser4") else { return }
        self.images = [photo1, photo2, photo3, photo4, photo5, photo6, photo7, photo8, photo9, photo10, photo11, photo12, photo13, photo14, photo15, photo16]
        
        self.photoBrowserView?.reloadPhotos()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: PhotoBrowserDataSource, PhotoBrowserDelegate {
    func photoBrowserViewForTransition() -> PhotoBrowserView? {
        return self.photoBrowserView
    }
    
    func numberOfPhotos(_ photoBrowser: PhotoBrowserView) -> Int {
        print("image count: \(self.images.count)")
        return self.images.count
    }
    
    func photoBrowser(_ photoBrowser: PhotoBrowserView, photoAtIndex index: Int, forImageView imageView: UIImageView, completion: @escaping (UIImage?) -> ()) {
        print("Loading image at \(index)")
        completion(self.images[index])
    }
}

