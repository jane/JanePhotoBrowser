Pod::Spec.new do |s|
  s.name          = "JanePhotoBrowser"
  s.version       = "0.0.1"
  s.summary       = "The Jane Photo Browser is a simple way to browse a group of photos"
  s.homepage      = "https://github.com/jane/JanePhotoBrowser"
  s.license       = 'MIT'
  s.author        = { "Jane" => "barlow@jane.com" }
  s.platform      = :ios, "8.0"
  s.source        = { :git => "https://github.com/jane/JanePhotoBrowser.git", :tag => "0.0.1" }
  s.source_files  = "Classes", "Classes/**/*.swift"
  s.exclude_files = "Classes/Exclude"
end
