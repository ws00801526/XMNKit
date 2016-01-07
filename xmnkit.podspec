#
#  Be sure to run `pod spec lint xmnkit.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "xmnkit"
  s.version      = "0.0.1"
  s.summary      = "收集个人一些常用类库"
  s.description  = <<-DESC
                   DESC
                   收集了个人常用的类库
  s.homepage     = "https://github.com/ws00801526/XMNKit"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"
  s.license      = "MIT (example)"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }

  s.author             = { "XMFraker" => "3057600441@qq.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/ws00801526/XMNKit.git", :commit => "5835a92f7843098729aa7acbe76b580228ba3342" }

  s.source_files  = "Classes", "Classes/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"


  s.subspec 'Core' do |core|
    core.source_files = 'XMNThirdExample/XMNThirdExample/XMNThirdInteraction/XMNThirdFunction.h','XMNThirdFunction/XMNThirdFunction/XMNThirdFunction+Supports.h'
    core.public_header_files = 'XMNThirdFunction/XMNThirdFunction/XMNThirdFunction.h','XMNThirdFunction/XMNThirdFunction/XMNThirdFunction+Supports.h'
    core.resource = 'lib/*.bundle'
  end

end
