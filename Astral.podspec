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
  s.version          = '2.1.0'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }

  s.summary          = 'An easy-to-use HTTP networking library'
  s.homepage         = 'https://github.com/hooliooo/Astral'

  s.author           = { 'Julio Alorro' => 'alorro3@gmail.com' }
  s.source           = { :git => 'https://github.com/hooliooo/Astral.git', :tag => s.version }

  s.ios.deployment_target     = '9.3'
  s.osx.deployment_target     = '10.11'
  s.tvos.deployment_target    = '11.0'
  s.watchos.deployment_target = '4.0'

  s.source_files = 'Sources/*.swift'
  s.requires_arc = true

  s.frameworks = 'Foundation'

  s.swift_version = '4.2'
end
