Pod::Spec.new do |s|

  s.name          = "ZJNetWork" 
  s.version       = "1.0.0"
  s.license       = "MIT"
  s.summary       = "网络请求"
  s.homepage      = "https://github.com/dale454071867/ZJNetWork"
  s.author        = { "zhoujie" => "454071867@qq.com" }
  s.source        = { :git => "https://github.com/dale454071867/ZJNetWork.git", :tag =>"1.0.0" }
  s.requires_arc  = true
  s.description   = <<-DESC
                   Fast encryption string, the current support for MD5 (16, 32), Sha1, Base64
                   DESC
  s.source_files  = "ZJNetWork/ZJNetWork/*.{h,m}","ZJNetWork/ZJNetWork/ZJNetworking/*.{h,m}","ZJNetWork/ZJNetWork/Utils/*.{h,m}"
  s.platform      = :ios, '7.0'
  s.dependency     'ZJCache','1.0.0'
  s.dependency     'DDLogger','1.1.1'
  s.dependency     'AFNetworking', '3.1.0'
  s.dependency     'Reachability','3.2'
  s.dependency     'MBProgressHUD','0.9.1'
  s.dependency     'MJExtension','3.0.3'
  
end