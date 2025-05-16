Pod::Spec.new do |s|
  s.name         = 'NeftaSDK'
  s.version      = '4.2.3'
  s.summary      = 'Nefta Ad Network SDK.'
  s.homepage     = 'https://docs.nefta.io/docs/ios'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'Tomaz Treven' => 'treven@nefta.io' }
  s.source       = { :git => 'https://github.com/Nefta-io/NeftaSDK-iOS.git', :tag => '4.2.3' }

  s.ios.deployment_target = '10.0'

  s.vendored_frameworks = 'NeftaSDK.xcframework'
end
