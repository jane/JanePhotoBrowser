# Jane Photo Browser

##Overview
The JanePhotoBrowser is a scrolling photo gallary.  The API to interface with the photo browser is similar to the APIs used in UITableViews and UICollectionViews and should have a familiar feel.

![PhotoBrowser](JanePhotoBrowser.gif)

##Setup
To get started, install the JanePhotoBrowser either using [Cocoapods]() or by adding the files in the `Class` folder into your project.

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

Implment the datasource methods and run your app!  If you are using the default implementation of the delegate methods, you will be able to tap a photo and it will transition to a full screen browser with the selected image focused.


