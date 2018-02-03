#
# Be sure to run `pod lib lint Astral.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Astral'
  s.module_name      = 'Astral'
  s.version          = '0.9.82'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }

  s.summary          = 'An HTTP networking library that uses protocols and Futures'
  s.homepage         = 'https://github.com/hooliooo/Astral'

  s.author           = { 'Julio Alorro' => 'alorro3@gmail.com' }
  s.source           = { :git => 'https://github.com/hooliooo/Astral.git', :tag => s.version }

  s.ios.deployment_target = '10.0'

  s.source_files = 'Sources/**/*.swift'
  s.requires_arc = true

  s.frameworks = 'Foundation'
  s.dependency 'BrightFutures'

  s.swift_version = '4.0'
end
