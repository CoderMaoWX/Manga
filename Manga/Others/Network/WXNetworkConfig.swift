//
//  WXNetworkConfig.swift
//  Manga
//
//  Created by Luke on 2021/8/20.
//

import Foundation
import YYCache

final class WXNetworkConfig {
    
    ///约定全局请求成功映射: key/value, (key可以是KeyPath模式进行匹配 如: data.status)
    var successStatusMap: (key: String, value: String)? = (key: "status", value: "200")
    
    ///约定全局请求提示key, 和失败时的默认提示文案
    var messageTipKeyAndFailInfo: [String : String]? = ["msg" : KWXRequestFailueTipMessage]
    
    ///请求遇到相应Code时触发通知 如: [ "notificationName" : 200 ]
    var codeNotifyDict: Dictionary<String, Int>? = nil
    
    /**
     * 是否需要全局管理 网络请求过程多链路回调<将要开始, 将要完成, 已经完成>
     * 注意: 此代理与请求对象中的<multicenterDelegate>代理互斥, 两者都实现时只会回调请求对象中的代理
     */
    var globleMulticenterDelegate: WXNetworkMulticenter? = nil

//    ///全局网络请求拦截类
//    var urlSessionProtocolClasses: Any.Type? = nil
//
//    ///是否禁止所有的网络请求设置代理抓包 (警告: 一定要放在首次发请求之前设值(例如+load方法中), 默认不禁止)
//    var forbidProxyCaught: Bool = false
//
//    ///是否打开多路径TCP服务，提供Wi-Fi和蜂窝之间的无缝切换，(默认关闭)
//    var openMultipathService: Bool = false
//
//    ///请求HUD时的类名
//    var requestLaodingCalss: AnyObject.Type? = nil
    
    ///是否显示请求HUD,全局开关, 默认显示
    var showRequestLaoding: Bool = true
    
    ///是否为正式上线环境: 如果为真,则下面的所有日志上传/打印将全都被忽略
    var isDistributionOnlineRelease: Bool = false
    
    ///在底层打印时提示环境,只作打印使用
    var networkHostTitle: String? = nil

	///是否打印接口响应日志打印，默认打印(release模式都不打印)
	var printfURLResponseLog: Bool = true
    
    ///全局上传请求日志到指定的URL
    var uploadRequestLogToURL: String? = nil
    
    ///日志系统抓包时的标签名
    var uploadCatchLogTagFlag: String? = nil
    
    /**
     * 是否打印统计上传日志，默认不打印
     * (如果是统计日志发出的请求则请在请求参数中带有key: KWXUploadAppsFlyerStatisticsKey)
     * */
    var printfStatisticsLog: Bool = false
    
    ///取请求缓存时用到的YYChache对象
    let networkDiskCache: YYDiskCache = {
        let userDocument = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first ?? ""
        let directryPath = (userDocument as NSString).appendingPathComponent(kWXNetworkResponseCacheKey)
        return YYDiskCache.init(path: directryPath)!
    }()

    ///单利对象
    static let shared = WXNetworkConfig()
    private init() {
	}
    
    ///清除所有缓存
    func clearWXNetworkAllRequestCache() {
        networkDiskCache.removeAllObjects()
    }
    
    ///清除指定缓存
    func clearWXNetworkCacheOfRequest(serverApi: WXRequestApi) {
        networkDiskCache.removeObject(forKey: serverApi.cacheKey)
    }
}

