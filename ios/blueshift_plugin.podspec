#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint blueshift_flutter_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'blueshift_plugin'
  s.version          = '0.0.1'
  s.summary          = 'Blueshift Flutter Plugin'
  s.description      = "Flutter plugin for the Blueshift Android and iOS SDK"
  s.homepage         = 'https://developer.blueshift.com/docs'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Blueshift' => 'support@getblueshift.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'BlueShift-iOS-SDK' , '2.4.0'
  s.platform = :ios, '10.0'
end
