Pod::Spec.new do |s|
  s.name         = 'NeftaSDK'
  s.version      = '3.1.15'
  s.summary      = 'SDK for Nefta mediation network.'
  s.homepage     = 'https://docs-adnetwork.nefta.io/docs/ios'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'Tomaz Treven' => 'treven@nefta.io' }
  s.source       = { :git => 'https://github.com/Nefta-io/NeftaSDK-iOS.git', :tag => '3.1.15' }

  s.ios.deployment_target = '10.0'

  s.vendored_frameworks = 'NeftaSDK.xcframework'
end
