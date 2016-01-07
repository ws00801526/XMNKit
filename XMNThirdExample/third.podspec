Pod::Spec.new do |s|
  s.name         = 'XMNThirdFunction'
  s.version      = '1.0.0'
  s.summary      = '封装第三方SDK 集成分享功能'
  s.description  = <<-DESC
                   移动分享集成,
                   目前支持微信,微博,QQ
                   DESC
  s.homepage     = 'https://github.com/ws00801526'
  s.license      = 'MIT'
  s.author       = { 'XMFraker' => '3057600441@qq.com' }
  s.platform     = :ios, '7.0.0'
  s.source       = { :git => 'https://github.com/PingPlusPlus/pingpp-ios.git', :tag => s.version }
  s.requires_arc = true
  s.default_subspec = 'Core'

  s.subspec 'Core' do |core|
    core.source_files = 'XMNThirdFunction/XMNThirdFunction/XMNThirdFunction.h','XMNThirdFunction/XMNThirdFunction/XMNThirdFunction+Supports.h'
    core.public_header_files = 'XMNThirdFunction/XMNThirdFunction/XMNThirdFunction.h','XMNThirdFunction/XMNThirdFunction/XMNThirdFunction+Supports.h'
    core.resource = 'lib/*.bundle'
  end

  s.subspec 'WeChat' do |wx|
    wx.ios.weak_frameworks = 'SystemConfiguration'
    wx.ios.library = 'ibz','libsqlite3.0','libc++'
    wx.source_files = 'XMNThirdFunction/XMNThirdFunction/XMNThirdFunction+WeChat.h'
    wx.public_header_files = 'XMNThirdFunction/XMNThirdFunction/XMNThirdFunction+WeChat.h'
    wx.vendored_libraries = 'XMNThirdFunction/XMNThirdFunction/APPSDK/WeChat/*.a'
    wx.dependency 'XMNThirdFunction/Core'

  s.subspec 'Weibo' do |wb|
    wb.ios.weak_frameworks = 'SystemConfiguration','ImageIO','CoreTelephony','QuartzCore'
    wb.source_files = 'XMNThirdFunction/XMNThirdFunction/XMNThirdFunction+Weibo.h'
    wb.public_header_files = 'XMNThirdFunction/XMNThirdFunction/XMNThirdFunction+Weibo.h'
    wb.vendored_libraries = 'XMNThirdFunction/XMNThirdFunction/APPSDK/Weibo/*.a'
    wb.dependency 'XMNThirdFunction/Core'
    wb.xcconfig = { 'OTHER_LDFLAGS' => '-ObjC' }  

  s.subspec 'QQ' do |qq|
    qq.ios.weak_frameworks = 'SystemConfiguration','ImageIO','CoreTelephony','QuartzCore'
    qq.source_files = 'XMNThirdFunction/XMNThirdFunction/XMNThirdFunction+QQ.h'
    qq.public_header_files = 'XMNThirdFunction/XMNThirdFunction/XMNThirdFunction+QQ.h'
    qq.ios.vendored_frameworks = 'XMNThirdFunction/XMNThirdFunction/APPSDK/QQ/TencentOpenAPI.framework'
    qq.dependency 'XMNThirdFunction/Core'


end