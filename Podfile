source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.kakaocorp.com/kakaopay-client/PrivatePods.git'

 platform :ios, '12.0'

target 'AnyWeather' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for AnyWeather
  pod 'PromisesSwift'
  pod 'Kakaopay/Common', :git => 'https://github.kakaocorp.com/kakaopay-client/ios-pay-common.git', :tag => $pay_common_version

  target 'AnyWeatherTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'AnyWeatherUITests' do
    # Pods for testing
  end

end
