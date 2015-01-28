#
# Be sure to run `pod lib lint XBAuthentication.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "XBAuthentication"
  s.version          = "0.1.0.7"
  s.summary          = "Authentication class to integrate with Plus Authenticate"
  s.description      = <<-DESC
                       Authentication class to integrate with Plus Authenticate. Plus Authenticate will be provided in Jan 15 2015.
                       DESC
  s.homepage         = "https://github.com/EugeneNguyen/XBAuthentication"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "eugenenguyen" => "xuanbinh91@gmail.com" }
  s.source           = { :git => "https://github.com/EugeneNguyen/XBAuthentication.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/LIBRETeamStudio'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.resource_bundles = {
    'XBAuthentication' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'ASIHTTPRequest'
  s.dependency 'JSONKit-NoWarning'
  s.dependency 'MD5Digest'
  s.dependency 'SDWebImage'
  s.dependency 'Facebook-iOS-SDK', '~> 3.21'
  s.dependency 'XBLanguage'
end