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
  s.version          = '0.6.5'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }

  s.summary          = 'An HTTP networking library that uses protocols and Futures'
  s.homepage         = 'https://github.com/hooliooo/Astral'
  s.description      = <<-DESC
                            Astral is a minimal HTTP Networking library that aims to simplify an application's networking layer by
                            abstracting the steps needed to create a network request into multiple objects. It aims to shy away
                            from the typical network layer singleton by encapsulating each part of network request as an object.
                        DESC

  s.author           = { 'Julio Alorro' => 'alorro3@gmail.com' }
  s.source           = { :git => 'https://github.com/hooliooo/Astral.git', :tag => s.version }

  s.ios.deployment_target = '10.0'

  s.source_files = 'Source/**/*.swift'

  s.frameworks = 'Foundation'
  s.dependency 'BrightFutures'
end
