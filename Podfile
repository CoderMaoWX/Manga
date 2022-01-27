source 'https://cdn.cocoapods.org/'
#source 'https://github.com/CocoaPods/Specs.git'

inhibit_all_warnings! #屏蔽所有warning
use_modular_headers!
# use_frameworks!

platform :ios, '10.0'

target 'iManga' do
  pod 'SnapKitExtend'
  pod 'PromiseKit'
  pod 'Moya'
  
  pod 'HandyJSON'
  pod 'SwiftyJSON'
  pod 'KakaJSON'
	pod 'CleanJSON'
  
  pod 'Kingfisher'
  pod 'Reusable'
  
  #Swift - 轮播图，文本轮播，支持左右箭头
  pod 'LLCycleScrollView'
  
  pod 'MJRefresh'
  pod 'HMSegmentedControl'
  pod 'IQKeyboardManagerSwift'
  
  pod 'FDFullscreenPopGesture'
  pod 'KVOController'
  
  #加载占位图
  #pod 'Shimmer'
  
  #空白占位图
  pod 'EmptyDataSet-Swift'
  
  pod 'JKSwiftExtension'
  
  pod 'YYCache'
  
  #自己写的网络库
  pod 'WXNetworkingSwift'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '10.0'
    end
  end
end
