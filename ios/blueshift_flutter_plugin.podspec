#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint blueshift_flutter_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'blueshift_flutter_plugin'
  s.version          = '0.0.1'
  s.summary          = 'Blueshift Flutter Plugin'
  s.description      = "Fluter plugin for the Blueshift Android and iOS SDK"
  s.homepage         = 'https://developer.blueshift.com/docs'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Blueshift' => 'support@getblueshift.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'BlueShift-iOS-SDK' , '~> 2.2.4'
  s.platform = :ios, '9.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
