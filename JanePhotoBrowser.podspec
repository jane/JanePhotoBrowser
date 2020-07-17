Pod::Spec.new do |s|
  s.name          = "JanePhotoBrowser"
  s.version       = "3.0.10"
  s.summary       = "The Jane Photo Browser is a simple way to browse a group of photos"
  s.homepage      = "https://github.com/jane/JanePhotoBrowser"
  s.license       = 'MIT'
  s.author        = { "Jane" => "ios@jane.com" }
  s.platform      = :ios, "11.0"
  s.source        = { :git => "https://github.com/jane/JanePhotoBrowser.git", :tag => s.version.to_s }
  s.source_files  = "JanePhotoBrowser/PhotoBrowser/**/*.swift"
  s.swift_version = "5"
end
