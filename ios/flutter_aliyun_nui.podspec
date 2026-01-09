#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_aliyun_nui.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_aliyun_nui'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin for Alibaba Cloud NUI SDK.'
  s.description      = <<-DESC
A Flutter plugin for Alibaba Cloud NUI (Natural User Interface) SDK, supporting speech recognition and voice interaction.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  
  # 暴露所有 .h 文件给 Swift，CocoaPods 会将它们扁平化到同一个目录
  s.public_header_files = 'Classes/**/*.h'
  s.swift_versions = ['5.0']
  s.static_framework = true
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # 添加本地framework
  s.vendored_frameworks = 'Frameworks/nuisdk.framework'
    
  # 添加系统框架依赖
  s.frameworks = 'AudioToolbox', 'AVFoundation', 'CoreAudio', 'Foundation', 'UIKit'
  
  # 添加系统库依赖
  s.libraries = 'c++', 'iconv'
  
  s.pod_target_xcconfig = { 
    'DEFINES_MODULE' => 'YES', 
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }
  # Privacy manifest
  s.resource_bundles = {'flutter_aliyun_nui_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
