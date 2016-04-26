//
//  ViewController.swift
//  JanePhotoBrowser
//
//  Copyright © 2016 Jane. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet weak var photoView: PhotoBrowserView?
    
    //MARK: - Private Variables
    private var images:[UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up data source and delegates
        self.photoView?.dataSource = self
        self.photoView?.delegate = self
        
        //Get an array of images
        guard let photo1 = UIImage(named: "photoBrowser1"),
                let photo2 = UIImage(named: "photoBrowser2"),
                let photo3 = UIImage(named: "photoBrowser3"),
                let photo4 = UIImage(named: "photoBrowser4") else { return }
        self.images = [photo1, photo2, photo3, photo4]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController:PhotoBrowserDataSource, PhotoBrowserDelegate {
    func numberOfPhotos(photoBrowser: PhotoBrowserView) -> Int {
        return self.images.count
    }
    
    func photoBrowser(photoBrowser: PhotoBrowserView, photoAtIndex index: Int) -> UIImage {
        return self.images[index]
    }
}

