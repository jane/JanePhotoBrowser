Pod::Spec.new do |s|
  s.name          = "JanePhotoBrowser"
  s.version       = "3.0.6"
  s.summary       = "The Jane Photo Browser is a simple way to browse a group of photos"
  s.homepage      = "https://github.com/jane/JanePhotoBrowser"
  s.license       = 'MIT'
  s.author        = { "Jane" => "ios@jane.com" }
  s.platform      = :ios, "11.0"
  s.source        = { :git => "https://github.com/jane/JanePhotoBrowser.git", :tag => s.version.to_s }
  s.source_files  = "JanePhotoBrowser/PhotoBrowser/**/*.swift"

  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #
  
  s.resources     = "JanePhotoBrowser/PhotoBrowser/*.xcassets"
  
  s.swift_version = "5"
end
