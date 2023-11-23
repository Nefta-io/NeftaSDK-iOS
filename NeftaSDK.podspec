Pod::Spec.new do |s|
  s.name         = 'NeftaSDK'
  s.version      = '3.1.5'
  s.summary      = 'SDK for Nefta mediation network.'
  s.homepage     = 'Nefta Mediation network SDK'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'Tomaz Treven' => 'treven@nefta.io' }
  s.source       = { :git => 'git@github.com:Nefta-io/Ads-for-iOS.git' :tag => '3.1.5' }

  s.ios.deployment_target = '11.0'

  s.vendored_frameworks = 'NeftaSDK.xcframework'
end
