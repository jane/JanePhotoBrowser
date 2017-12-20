Pod::Spec.new do |s|
  s.name          = "JanePhotoBrowser"
  s.version       = "1.0.3"
  s.summary       = "The Jane Photo Browser is a simple way to browse a group of photos"
  s.homepage      = "https://github.com/jane/JanePhotoBrowser"
  s.license       = 'MIT'
  s.author        = { "Jane" => "barlow@jane.com" }
  s.platform      = :ios, "8.0"
  s.source        = { :git => "https://github.com/jane/JanePhotoBrowser.git", :tag => s.version.to_s }
  s.source_files  = "JanePhotoBrowser/JanePhotoBrowser/Classes/*.swift"
  s.exclude_files = "JanePhotoBrowser/JanePhotoBrowser/Classes/Exclude"
end
