Pod::Spec.new do |s|
s.name = "CBScan"
s.version = '1.0.1'
s.license = 'MIT'
# Copyright (c2019) CBin. All rights reserved
s.summary = "条码、二维码扫描，带提示音"
s.homepage = "https://github.com/junedeyu/CBScan"
s.authors = { 'junedeyu' => '497303054@qq.com' }
s.source = { :git => "https://github.com/junedeyu/CBScan.git", :tag => s.version.to_s}
s.requires_arc = true
s.platform = :ios, '9.0'
s.ios.deployment_target = '9.0'
s.source_files = 'CBScan/*.{h,m,png,mp3}'
s.frameworks = 'AVFoundation'
s.dependency 'Masonry'

end
