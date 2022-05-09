Pod::Spec.new do |s|
  s.name             = 'SwiftUINavigation'
  s.version          = '1.0.1'
  s.summary          = 'UIKit like navigation controller in SwiftUI'

  s.description      = <<-DESC
SwiftUINavigation provides NavigationController which can be used to push/pop views in SwiftUI exactly like UIKit's UINavigationController.
                       DESC

  s.homepage         = 'https://github.com/bhimsenp/SwiftUINavigation'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Bhimsen Padalkar' => 'bhim.padalkar@gmail.com' }
  s.source           = { :git => 'https://github.com/bhimsenp/SwiftUINavigation.git', :tag => s.version.to_s }
  s.swift_versions     = ['5.0']
  s.ios.deployment_target = '13.0'

  s.source_files = 'Sources/**/*'
end
