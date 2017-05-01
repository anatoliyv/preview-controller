#
# Be sure to run `pod lib lint PreviewController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'PreviewController'
    s.version          = '0.1.0'
    s.summary          = 'Bunch of controller to preview different kind of data'

    s.description      = <<-DESC
Preview controllers to preview different kind of data with some useful features:
    * Image preview (by url, by image) include close and share buttons
    * Video preview: developing is in progerss
    * Web preview: developing is in progress
DESC

    s.homepage         = 'https://github.com/anatoliyv/preview-controller'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Anatoliy Voropay' => 'anatoliy.voropay@gmail.com' }
    s.source           = { :git => 'https://github.com/anatoliyv/preview-controller.git', :tag => s.version.to_s }
    s.social_media_url = 'https://twitter.com/anatoliy_v'
    s.ios.deployment_target = '9.0'
    s.source_files     = 'PreviewController/Classes/**/*'
    s.resources        = 'PreviewController/Assets/**/*'
    s.frameworks       = 'UIKit'
end
