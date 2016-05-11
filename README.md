# Jane Photo Browser

##Overview
The JanePhotoBrowser is a scrolling photo gallary.  The API to interface with the photo browser is similar to the APIs used in UITableViews and UICollectionViews and should have a familiar feel.

![PhotoBrowser](JanePhotoBrowser.gif)

##Features
* **Easy setup:**  Just add a PhotoBrowserView to your ViewController and implement the datasource and delegate
* **Full Screen Browser:** Tap on an image in the PhotoView to launch the full screen browser.
* **Swipe Gestures:** Close the full screen browser by tapping the close button, tapping the image, or swiping up.
* **Swift:** This project was writen completely in Swift.

##Setup
To get started, install the JanePhotoBrowser either using [Cocoapods](https://cocoapods.org/) or by adding the files in the `Class` folder into your project.

Add a PhotoBrowserView either in the Storyboard or programmatically by calling one of the initializers and set the datasource and delegate.  

```swift
@IBOutlet weak var photoView:PhotoBrowserView?

override func viewDidLoad() {
	super.viewDidLoad
	
	self.photoView.dataSource = self
	self.photoView.delegate = self
}
```

> If your delegate is a UIViewController, then the default implementation of the delegate methods is done for you in the PhotoBrowserDelegate protocol extension.

###Data Source
The data source protocol supplies methods for the PhotoBrowser to get the images that need to be included.

**Data Source Protocol:**

```swift
public protocol PhotoBrowserDataSource:class {
    func photoBrowser(photoBrowser:PhotoBrowserView, photoAtIndex index: Int, forCell cell:PhotoBrowserViewCell) -> UIImage
    func numberOfPhotos(photoBrowser:PhotoBrowserView) -> Int
}
```

The `numberOfPhotos` method lets the photo browser know how many photos to expect.  This is similar to the `UITableViewDataSource` and `UICollectionViewDataSource` methods.

`photoBrowser(photoBrowser:PhotoBrowserView, photoAtIndex index: Int, forCell cell:PhotoBrowserViewCell) -> UIImage` returns an `UIImage` for a given index.  If you already have a list of images, you will just return them in this method.  If you have to pull the image from a resource online, you may want to do something like the following:

```swift
func photoBrowser(photoBrowser: PhotoBrowserView, photoAtIndex index: Int, forCell cell:PhotoBrowserViewCell) -> UIImage {
    guard let URL = self.deal?.allImageUrls()[index] else { return UIImage() }
    
    var returnImage: UIImage = self.loadingImage
    
    //Get image from cache or online if not cached.  
    //Note that Image caching is not included in the project.
    MyImageCacheClass.image(atURL: URL) { (image) in
    	 //If the image was fetched online, this method may have already 
    	 //returned the loading image, so set the image on the 
    	 //photoBrowserViewCell as well as setting the returnImage.
        cell.imageView.image = image
        returnImage = image
    }
    return returnImage
}
```

##License
This project is made available with the MIT License.

##Feedback
If you have any issues or feature request for this project, please create an issue and/or send us a pull request.

We hope you enjoy the JanePhotoBrowser!