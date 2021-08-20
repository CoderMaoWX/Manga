//
//  WXNetworkConfig.swift
//  Manga
//
//  Created by Luke on 2021/8/20.
//

import Foundation

final class WXNetworkConfig {
    
    ///各站自定义请求成功标识
    var statusKey: String = "status"
    var statusCode: Int = 200
    var messageKey: String = "msg"
    
    ///需要解析Model时的全局key,(可选)
    var customModelKey: String? = nil
    
    ///请求失败时的默认提示
    var requestFailDefaultMessage: String? = nil
    
    ///全局网络请求拦截类
    var urlSessionProtocolClasses: Any.Type? = nil
    
    ///请求遇到相应Code时触发通知: [ "notificationName" : 200 ]
    var errorCodeNotifyDict: Dictionary<String, Int>? = nil
    
    /**
     * 是否需要全局管理 网络请求过程多通道回调<将要开始, 将要完成, 已经完成>
     * 注意: 此代理与请求对象中的<multicenterDelegate>代理互斥, 两者都实现时只会回调请求对象中的代理
     */
    var globleMulticenterDelegate: WXNetworkMulticenter? = nil
    
    ///是否禁止所有的网络请求设置代理抓包 (警告: 一定要放在首次发请求之前设值(例如+load方法中), 默认不禁止)
    var forbidProxyCaught: Bool = false
    
    ///是否打开多路径TCP服务，提供Wi-Fi和蜂窝之间的无缝切换，(默认关闭)
    var openMultipathService: Bool = false
    
    ///请求HUD时的类名
    var requestLaodingCalss: AnyObject.Type? = nil
    
    ///请求HUD全局开关, 默认不显示HUD
    var showRequestLaoding: Bool = false
    
    ///是否为正式上线环境: 如果为真,则下面的所有日志上传/打印将全都被忽略
    var isDistributionOnlineRelease: Bool = false
    
    ///在底层打印时提示环境,只作打印使用
    var networkHostTitle: String? = nil
    
    ///上传请求日志到指定的URL
    var uploadRequestLogToUrl: String? = nil
    
    ///日志系统抓包时的标签名
    var uploadCatchLogTagStr: String? = nil
    
    ///是否上传日志到远程日志系统，默认不上传
    var uploadResponseJsonToLogSystem: Bool = false
    
    ///是否关闭打印: 接口响应日志，默认关闭
    var closeUrlResponsePrintfLog: Bool = false
    
    /**
     * 是否关闭打印: 统计上传日志，默认关闭
     * (如果是统计日志发出的请求则请在请求参数中带有key: KWXUploadAppsFlyerStatisticsKey)
     * */
    var closeStatisticsPrintfLog: Bool = false

    ///单利对象
    static let shared = WXNetworkConfig()
    private init() {
        closeUrlResponsePrintfLog = true
        closeStatisticsPrintfLog = true
    }
    
    ///清除所有缓存
    func clearWXNetworkAllRequestCache() {
        
    }
    
    ///清除指定缓存
    func clearWXNetworkCacheOfRequest(serverApi: WXNetworkRequest) {
        
    }
}

