//
//  WXNetworkRequest.swift
//  Manga
//
//  Created by 610582 on 2021/8/20.
//

import Foundation
import Alamofire

enum WXRequestMulticenterType: Int {
    case WillStart
    case WillStop
    case DidCompletion
}

typealias WXNetworkResponseBlock = (WXResponseModel) -> ()
typealias WXNetworkSuccessBlock = (Any) -> ()
typealias WXNetworkFailureBlock = (Error) -> ()

class WXBaseRequest: NSObject {
    ///请求Method类型
    var requestMethod: HTTPMethod = .post
    ///请求地址
    var requestURL: String = ""
    ///请求参数
    var parameters: Dictionary<String, String>? = nil
    ///请求超时，默认30s
    var timeOut: Int = 30
    ///请求自定义头信息
    var requestHeaderDict: Dictionary<String, String>? = nil
    ///底层最终的请求参数 (页面上可实现<WXPackParameters>协议来实现重新包装请求参数)
    private(set) var finalParameters: Dictionary<String, String>? = nil
    ///请求任务对象
    private(set) var requestDataTask: URLSessionDataTask? = nil
    ///求Session对象
    private(set) var urlSession: URLSession? = nil
    
//    fileprivate var setupHttpSessionManager:  = <#value#>
    
    lazy var manager: SessionManager = {
        let config: URLSessionConfiguration = URLSessionConfiguration.default
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            ///正式环境的证书配置,修改成自己项目的正式url
            "www.baidu.com": .pinCertificates(
                certificates: ServerTrustPolicy.certificates(),
                validateCertificateChain: true,
                validateHost: true
            ),
            ///测试环境的证书配置,不验证证书,无脑通过
            "192.168.1.213:8002": .disableEvaluation
            ]
        //config.httpAdditionalHeaders = ewHttpHeaders
        config.timeoutIntervalForRequest = TimeInterval(timeOut)
        //根据config创建manager
        return SessionManager(configuration: config,
                                 delegate: SessionDelegate(),
                                 serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies))
    }()
    
    /// 网络请求方法 (不做任何额外处理的原始Alamofire请求，页面上不建议直接用，请使用子类请求方法)
    /// - Parameters:
    ///   - successClosure: 请求成功回调
    ///   - failureClosure: 请求失败回调
    /// - Returns: 求Session对象
    @discardableResult
    func baseRequestBlock(successClosure: @escaping WXNetworkSuccessBlock,
                          failureClosure: @escaping WXNetworkFailureBlock ) -> DataRequest {
        return manager.request(requestURL,
                               method: requestMethod,
                               parameters: parameters,
                               headers: requestHeaderDict).responseJSON { response in
                                
                                switch response.result {
                                case .success(let json):
                                    successClosure(json)
                                    
                                case .failure(let error):
                                    failureClosure(error)
                                }
                               }
    }
}

///包装的响应数据
class WXResponseModel: NSObject {
    var isSuccess: Bool = false
    var isCacheData: Bool = false
    var responseDuration: TimeInterval? = nil
    var responseCode: Int? = nil
    var responseCustomModel: AnyObject? = nil
    var responseObject: AnyObject? = nil
    var responseDict: Dictionary<String, String>? = nil
    var responseMsg: String? = nil
    var error: NSError? = nil
    var urlResponse: HTTPURLResponse? = nil
    var originalRequest: URLRequest? = nil
    fileprivate (set) var apiUniquelyIp: String?  = nil
}

typealias WXCacheResponseClosure = (WXResponseModel) -> (Dictionary<String, String>)

class WXNetworkRequest: WXBaseRequest {
    
    ///请求成功时是否需要自动缓存响应数据, 默认不缓存
    var autoCacheResponse: Bool = false
    
    ///请求成功时自定义响应缓存数据, (返回的字典为此次需要保存的缓存数据, 返回nil时,底层则不缓存)
    var cacheResponseClosure: WXCacheResponseClosure? = nil
    
    ///单独设置响应Model时的解析key, 否则使用单例中的全局解析 WXNetworkConfig.customModelKey
    var customModelKey: String? = nil
    
    ///请求成功返回后解析成相应的Model返回
    var responseCustomModelCalss: Any.Type? = nil
    
    ///请求转圈的父视图
    var loadingSuperView: UIView? = nil
    
    ///请求失败之后重新请求次数, (每次重试时间隔3秒)
    var retryCountWhenFailure: Int? = nil
    
    ///网络请求过程多通道回调<将要开始, 将要停止, 已经完成>
    /// 注意: 如果没有实现此代理则会回调单例中的全局代理<globleMulticenterDelegate>
    var multicenterDelegate: WXNetworkMulticenter? = nil
    
    ///可以用来添加几个accossories对象 来做额外的插件等特殊功能
    ///如: (请求HUD, 加解密, 自定义打印, 上传统计)
    var requestAccessories: [WXNetworkMulticenter]? = nil
    
    
    ///以下为私有属性,外部可以忽略
    
    fileprivate (set) var retryCount: Int = 0
    fileprivate (set) var cacheKey: String = ""
    fileprivate (set) var apiUniquelyIp: String = ""
    fileprivate (set) var requestDuration: Double = 0
    fileprivate (set) var responseDelegate: WXNetworkDelegate? = nil
    fileprivate (set) var parmatersJsonString: String = ""
    fileprivate (set) var managerRequestKey: String = ""
    fileprivate (set) var configResponseCallback: WXNetworkResponseBlock? = nil
    
    @discardableResult
    func startRequest(responseBlock: WXNetworkResponseBlock) -> DataRequest? {
        guard let _ = URL(string: requestURL) else {
            debugLog("\n❌❌❌无效的请求地址= \(requestURL)")
            
            
            return nil
        }
        
        
        return nil
    }
    
    func configResponseBlock(responseBlock: @escaping WXNetworkResponseBlock, responseObj: AnyObject?) {
        if responseObj == nil {
            if let retryCountWhenFailure = retryCountWhenFailure,
               retryCount < retryCountWhenFailure,
               let error = responseObj as? Error,
               error._code == -999 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.retryCount += 1
                    self.startRequest(responseBlock: responseBlock)
                }
            }
            
            
        } else {
            
        }
    }
    
    func getCurrentTimestamp() -> Double {
        let dat = NSDate.init(timeIntervalSinceNow: 0)
        return dat.timeIntervalSince1970 * 1000
    }
    
    func judgeShowLoading(show: Bool) {
        let config = WXNetworkConfig.shared.showRequestLaoding
        guard config else { return }
        if let loadingSuperView = loadingSuperView {
            DispatchQueue.main.async {
                if show {
                    showLoading(toView: loadingSuperView)
                } else {
                    hideLoading(from: loadingSuperView)
                }
            }
        }
    }
    
    var configFailMessage: String {
        return KWXRequestFailueTipMessage
    }
    
    
    func configResponseModel(responseObj: AnyObject) -> WXResponseModel? {
        let rspModel = WXResponseModel()
        rspModel.responseDuration  = getCurrentTimestamp() - self.requestDuration
        rspModel.apiUniquelyIp     = apiUniquelyIp
        rspModel.responseObject    = responseObj
        
        rspModel.originalRequest = requestDataTask?.originalRequest
        
        if let urlResponse = requestDataTask?.response as? HTTPURLResponse {
            rspModel.urlResponse = urlResponse
        }
        
        if let error = responseObj as? Error {
            rspModel.isSuccess     = false
            rspModel.isCacheData   = false
            rspModel.responseMsg   = configFailMessage
            rspModel.responseCode  = error._code
            rspModel.error = NSError(domain: configFailMessage, code: error._code, userInfo: nil)
            
        } else {
            let responseDict = packagingResponseObj(responseObj: responseObj, responseModel: rspModel)
            let config = WXNetworkConfig.shared
            let responseCode = responseDict[config.statusKey]
            let code = Int(responseCode ?? "0")!
            rspModel.responseDict = responseDict
            rspModel.responseCode = code
            if let _ = responseCode, code == config.statusCode {
                rspModel.isSuccess = true
            }
            
            if let msg = responseDict[config.messageKey] {
                rspModel.responseMsg = msg
            }
            
            if rspModel.isSuccess {
                
            } else {
                rspModel.responseMsg = rspModel.responseMsg ?? configFailMessage
                rspModel.error = NSError(domain: rspModel.responseMsg!, code: code, userInfo: responseDict)
            }
        }
        if rspModel.isCacheData == false {
            handleMulticenter(type: .WillStop, responseModel: rspModel)
        }
        return nil
        
    }
    
    func handleMulticenter(type: WXRequestMulticenterType, responseModel: WXResponseModel) {
        
        var delegate: WXNetworkMulticenter?
        if let tmpDelegate = multicenterDelegate {
            delegate = tmpDelegate
        } else {
            delegate = WXNetworkConfig.shared.globleMulticenterDelegate
        }
        switch type {
        case .WillStart:
            judgeShowLoading(show: true)
            requestDuration = getCurrentTimestamp()
            
            delegate?.requestWillStart(request: self)
            
            if let requestAccessories = requestAccessories {
                for accessory in requestAccessories {
                    accessory.requestWillStart(request: self)
                }
            }
            
            
        case .WillStop:


        case .DidCompletion:

        default:
            break
        }
        
        
    }
    
    
    func packagingResponseObj(responseObj: AnyObject, responseModel: WXResponseModel) -> Dictionary<String, String> {
        let config = WXNetworkConfig.shared
        var responseDcit: [String : String] = [:]
        
        if responseObj is Dictionary<String, String> {
            responseDcit += responseObj as! Dictionary<String, String>
            
            if let _ = responseDcit[kWXRequestDataFromCacheKey] {
                responseDcit.removeValue(forKey: kWXRequestDataFromCacheKey)
                responseModel.isCacheData = true
                
            } else if responseObj is Data {
                let rspData = responseObj.mutableCopy()
                if let rspData = rspData as? Data {
                    responseModel.responseObject = rspData as AnyObject
                }
            } else {
                //注意:不能直接赋值responseObj, 因为插件库那边会dataWithJSONObject打印会崩溃
                //responseDcit[config.customModelKey] = [responseObj description];
            }
            //只要返回为非Error就包装一个公共的key, 防止页面当失败解析
            if responseDcit[config.statusKey] == nil {
                responseDcit[config.statusKey] = "\(config.statusCode)"
            }
        }
        return responseDcit
    }

    
}
