Pod::Spec.new do |s|
  s.name         = 'NeftaSDK'
  s.version      = '3.2.5'
  s.summary      = 'Nefta Ad Network SDK.'
  s.homepage     = 'https://docs.nefta.io/docs/ios'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'Tomaz Treven' => 'treven@nefta.io' }
  s.source       = { :git => 'https://github.com/Nefta-io/NeftaSDK-iOS.git', :tag => '3.2.5' }

  s.ios.deployment_target = '10.0'

  s.vendored_frameworks = 'NeftaSDK.xcframework'
end
