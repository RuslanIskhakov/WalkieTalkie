use_frameworks!

target "WalkieTalkie" do	
    platform :ios, '13.0'
    pod 'RxSwift', '6.5.0'
    pod 'RxCocoa', '6.5.0'
end

# RxTest and RxBlocking make the most sense in the context of unit/integration tests
target "WalkieTalkieTests" do
    platform :ios, '13.0'
    pod 'RxBlocking', '6.5.0'
    pod 'RxTest', '6.5.0'
end

post_install do |pi|
  pi.pods_project.targets.each do |t|
    t.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end
