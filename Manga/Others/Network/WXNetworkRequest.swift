//
//  WXNetworkRequest.swift
//  Manga
//
//  Created by 610582 on 2021/8/20.
//

import Foundation
import Alamofire
import JKSwiftExtension
import KakaJSON

enum WXRequestMulticenterType: Int {
    case WillStart
    case WillStop
    case DidCompletion
}

typealias WXNetworkResponseBlock = (WXResponseModel) -> ()
typealias WXNetworkSuccessBlock = (AnyObject) -> ()
typealias WXNetworkFailureBlock = (AnyObject) -> ()

class WXBaseRequest: NSObject {
    ///请求Method类型
    var requestMethod: HTTPMethod = .post
    ///请求地址
    var requestURL: String = ""
    ///请求参数
    var parameters: Dictionary<String, Any>? = nil
    ///请求超时，默认30s
    var timeOut: Int = 30
    ///请求自定义头信息
    var requestHeaderDict: Dictionary<String, String>? = nil
    ///请求任务对象
    private(set) var requestDataTask: DataRequest? = nil
    
    ///底层最终的请求参数 (页面上可实现<WXPackParameters>协议来实现重新包装请求参数)
    lazy var finalParameters: Dictionary<String, Any>? = {
        var parameters = parameters
        if conforms(to: WXPackParameters.self) {
            parameters = (self as? WXPackParameters)?.parametersWillTransformFromOriginParamete(parameters: parameters)
        }
        return parameters
    }()

//    lazy var manager: Session = {
//        let config: URLSessionConfiguration = URLSessionConfiguration.default
//        let serverTrustPolicies: [String: ServerTrustPolicy] = [
//            ///正式环境的证书配置,修改成自己项目的正式url
//            "www.baidu.com": .pinCertificates(
//                certificates: ServerTrustPolicy.certificates(),
//                validateCertificateChain: true,
//                validateHost: true
//            ),
//            ///测试环境的证书配置,不验证证书,无脑通过
//            "192.168.1.213:8002": .disableEvaluation
//            ]
//        //config.httpAdditionalHeaders = ewHttpHeaders
//        config.timeoutIntervalForRequest = TimeInterval(timeOut)
//        config.requestCachePolicy = .reloadIgnoringLocalCacheData
//        //根据config创建manager
//        return Session(configuration: config,
//                                 delegate: SessionDelegate(),
//                                 serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies))
//    }()
    
    /// 网络请求方法 (不做任何额外处理的原始Alamofire请求，页面上不建议直接用，请使用子类请求方法)
    /// - Parameters:
    ///   - successClosure: 请求成功回调
    ///   - failureClosure: 请求失败回调
    /// - Returns: 求Session对象
    @discardableResult
    func baseRequestBlock(successClosure: WXNetworkSuccessBlock?,
                          failureClosure: WXNetworkFailureBlock? ) -> DataRequest {

        let dataRequest = AF.request(requestURL,
                                     method: requestMethod,
                                     parameters: finalParameters,
                                     headers: HTTPHeaders(requestHeaderDict ?? [:])).responseJSON { response in
            switch response.result {
            case .success(let json):
                if let successClosure = successClosure {
                    successClosure(json as AnyObject)
                }
            case .failure(let error):
                if let failureClosure = failureClosure {
                    failureClosure(error as AnyObject)
                }
            }
           }
        requestDataTask = dataRequest
        return dataRequest
    }
}

///包装的响应数据
class WXResponseModel: NSObject {
    var isSuccess: Bool = false
    var isCacheData: Bool = false
    var responseDuration: TimeInterval? = nil
    var responseCode: Int? = nil
    var responseCustomModel: Convertible? = nil
    var responseObject: AnyObject? = nil
    var responseDict: Dictionary<String, Any>? = nil
    var responseMsg: String? = nil
    var error: NSError? = nil
    var urlResponse: HTTPURLResponse? = nil
    var originalRequest: URLRequest? = nil
    fileprivate (set) var apiUniquelyIp: String?  = nil
    
    func configModel(requestApi: WXNetworkRequest, responseDict: Dictionary<String, Any>) {
        
        guard let modelCalss = requestApi.responseCustomModelCalss else { return }
        var customModelKeyPath = requestApi.customModelKeyPath
        
        if customModelKeyPath == nil {
            customModelKeyPath = WXNetworkConfig.shared.customModelKeyPath
            
        } else if let modelKey = customModelKeyPath, modelKey.count == 0 {
            customModelKeyPath = WXNetworkConfig.shared.customModelKeyPath
        }
        
        if let customModelKeyPath = customModelKeyPath, customModelKeyPath.count > 0 {
            var lastValueDict: Any?
            
            if customModelKeyPath.contains(".") {
                let customModelKeyPathArray =  customModelKeyPath.components(separatedBy: ".")
                lastValueDict = responseDict[customModelKeyPathArray.first!]
                
                for modelKey in customModelKeyPathArray {
                    if lastValueDict == nil {
                        return
                    } else {
                        lastValueDict = fetchDictValue(respKey: modelKey, respValue: lastValueDict)
                    }
                }
            } else {
                lastValueDict = responseDict[customModelKeyPath]
            }
           
            if let customModelValue = lastValueDict as? Dictionary<String, Any> {
                responseCustomModel = customModelValue.kj.model(type: modelCalss)
                
            }  else if let modelObj = lastValueDict as? Array<Any> {
                responseCustomModel = modelObj.kj.modelArray(type: modelCalss) as? Convertible
            }
        }
    }
    
    func fetchDictValue(respKey: String, respValue: Any?) -> Any? {
        if let respDict = respValue as? Dictionary<String, Any> {
            for (dictKey, dictValue) in respDict {
                if respKey == dictKey {
                    return dictValue
                }
            }
        }
        return nil
    }
}

typealias WXCacheResponseClosure = (WXResponseModel) -> (Dictionary<String, Any>?)

class WXNetworkRequest: WXBaseRequest {
    
    ///请求成功时是否需要自动缓存响应数据, 默认不缓存
    var autoCacheResponse: Bool = false
    
    ///请求成功时自定义响应缓存数据, (返回的字典为此次需要保存的缓存数据, 返回nil时,底层则不缓存)
    var cacheResponseBlock: WXCacheResponseClosure? = nil
    
    ///单独设置响应Model时的解析key, 否则使用单例中的全局解析 WXNetworkConfig.customModelKeyPath
    var customModelKeyPath: String? = nil
    
    ///请求成功返回后解析成相应的Model返回
    var responseCustomModelCalss: Convertible.Type? = nil
    
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
    fileprivate (set) var apiUniquelyIp: String = ""
    fileprivate (set) var requestDuration: Double = 0
    fileprivate (set) var managerRequestKey: String = ""
    
    @discardableResult
    func startRequest(responseBlock: @escaping WXNetworkResponseBlock) -> DataRequest? {
        guard let _ = URL(string: requestURL) else {
            debugLog("\n❌❌❌无效的请求地址= \(requestURL)")
            configResponseBlock(responseBlock: responseBlock, responseObj: nil)
            return nil
        }
        let networkBlock: (AnyObject) -> () = { responseObj in
            self.configResponseBlock(responseBlock: responseBlock, responseObj: responseObj)
        }
        if checkRequestInCache() {
            readRequestCacheWithBlock(fetchCacheBlock: networkBlock)
        }
        handleMulticenter(type: .WillStart, responseModel: WXResponseModel())
        
        let dataRequest = baseRequestBlock(successClosure: networkBlock, failureClosure: networkBlock)
        
        if WXNetworkConfig.shared.closeUrlResponsePrintfLog == false {
            debugLog("\n👉👉👉页面已发出请求=", requestURL)
        }
        return dataRequest
    }
    
    func configResponseBlock(responseBlock: @escaping WXNetworkResponseBlock, responseObj: AnyObject?) {
        if responseObj != nil {
            if let retryCountWhenFailure = retryCountWhenFailure,
               retryCount < retryCountWhenFailure,
               let error = responseObj as? Error,
               error._code == -999 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.retryCount += 1
                    self.startRequest(responseBlock: responseBlock)
                }
            } else {
                let responseModel = configResponseModel(responseObj: responseObj!)
                responseBlock(responseModel)
                handleMulticenter(type: .DidCompletion, responseModel: responseModel)
            }
        } else {
            let error = NSError(domain: configFailMessage, code: -444, userInfo: nil)
            let responseModel = configResponseModel(responseObj: error)
            responseBlock(responseModel)
            handleMulticenter(type: .DidCompletion, responseModel: responseModel)
        }
    }
    
    func checkPostNotification(responseModel: WXResponseModel) {
        let notifyDict = WXNetworkConfig.shared.errorCodeNotifyDict
        if let responseCode = responseModel.responseCode, let notifyDict = notifyDict {
            for (key, value) in notifyDict where responseCode == value {
                NotificationCenter.default.post(name: NSNotification.Name(key), object: responseModel)
            }
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
            if show {
                showLoading(toView: loadingSuperView)
            } else {
                hideLoading(from: loadingSuperView)
            }
        }
    }
    
    var configFailMessage: String {
        return KWXRequestFailueTipMessage
    }
    
    func configResponseModel(responseObj: AnyObject) -> WXResponseModel {
        let rspModel = WXResponseModel()
        rspModel.responseDuration  = getCurrentTimestamp() - self.requestDuration
        rspModel.apiUniquelyIp     = apiUniquelyIp
        rspModel.responseObject    = responseObj
        
        rspModel.originalRequest = requestDataTask?.request
        rspModel.urlResponse = requestDataTask?.response

        var code: Int = -1
        if let error = responseObj as? Error {
            code = error._code
        } else if let error = responseObj as? NSError {
            code = error.code
        }
        
        if code != -1 { //错误
            rspModel.isSuccess     = false
            rspModel.isCacheData   = false
            rspModel.responseMsg   = configFailMessage
            rspModel.responseCode  = code
            rspModel.error = NSError(domain: configFailMessage, code: code, userInfo: nil)
            
        } else {
            let responseDict = packagingResponseObj(responseObj: responseObj, responseModel: rspModel)
            let config = WXNetworkConfig.shared
            let responseCode = responseDict[config.statusKey]
            let code = Int((responseCode as? String) ?? "0")!
            rspModel.responseDict = responseDict
            rspModel.responseCode = code
            if let _ = responseCode, code == config.statusCode {
                rspModel.isSuccess = true
            }
            if let msg = responseDict[config.messageKey] {
                rspModel.responseMsg = msg as? String
            }
            if rspModel.isSuccess {
                rspModel.configModel(requestApi: self, responseDict: responseDict)
            } else {
                rspModel.responseMsg = rspModel.responseMsg ?? configFailMessage
                rspModel.error = NSError(domain: rspModel.responseMsg!, code: code, userInfo: responseDict)
            }
        }
        if rspModel.isCacheData == false {
            handleMulticenter(type: .WillStop, responseModel: rspModel)
        }
        return rspModel
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
            if WXNetworkConfig.shared.closeUrlResponsePrintfLog == false {
                let logHeader = WXNetworkPlugin.appendingPrintfLogHeader(request: self, responseModel: responseModel)
                let logFooter = WXNetworkPlugin.appendingPrintfLogFooter(responseModel: responseModel)
                debugLog("\(logHeader)", "\(logFooter)");
            }
            
            delegate?.requestWillStop(request: self, responseModel: responseModel)
            
            if let requestAccessories = requestAccessories {
                for accessory in requestAccessories {
                    accessory.requestWillStop(request: self, responseModel: responseModel)
                }
            }
            
        case .DidCompletion:
            judgeShowLoading(show: false)
            checkPostNotification(responseModel: responseModel)
            WXNetworkPlugin.uploadNetworkResponseJson(request: self, responseModel: responseModel)
            
            delegate?.requestDidCompletion(request: self, responseModel: responseModel)
            
            if let requestAccessories = requestAccessories {
                for accessory in requestAccessories {
                    accessory.requestDidCompletion(request: self, responseModel: responseModel)
                }
            }
            // save as much as possible at the end
            if responseModel.isCacheData == false {
                saveResponseObjToCache(responseModel: responseModel)
            }
        }
    }
    
    //MARK: - DealWithCache
    
    lazy var cacheKey: String = {
        if cacheResponseBlock != nil || autoCacheResponse {
            return managerRequestKey.jk.md5Encrypt()
        }
        return ""
    }()
    
    func checkRequestInCache() -> Bool {
        if cacheResponseBlock != nil || autoCacheResponse {
            let networkCache = WXNetworkConfig.shared.networkDiskCache
            if networkCache.containsObject(forKey: cacheKey) {
                return true
            }
        }
        return false
    }
    
    func readRequestCacheWithBlock(fetchCacheBlock: @escaping (AnyObject) -> ()) {
        if cacheResponseBlock != nil || autoCacheResponse {
            let networkCache = WXNetworkConfig.shared.networkDiskCache
            
            networkCache.object(forKey: cacheKey) { key, cacheObject in
                guard let cacheObject = cacheObject, var cacheDcit = cacheObject as? Dictionary<String, Any> else { return }
                cacheDcit[kWXRequestDataFromCacheKey] = true
                if Thread.isMainThread {
                    fetchCacheBlock(cacheDcit as AnyObject)
                } else {
                    DispatchQueue.main.async {
                        fetchCacheBlock(cacheDcit as AnyObject)
                    }
                }
            }
        }
    }
    
    func saveResponseObjToCache(responseModel: WXResponseModel) {
        if let cacheBlock = cacheResponseBlock {
            let customResponseObject = cacheBlock(responseModel)
            if let saveCache = customResponseObject {
                let networkCache = WXNetworkConfig.shared.networkDiskCache
                networkCache.setObject(saveCache as NSCoding, forKey: cacheKey)
            }
        } else if autoCacheResponse {
            if let responseObject = responseModel.responseObject {
                let networkCache = WXNetworkConfig.shared.networkDiskCache
                networkCache.setObject(responseObject as? NSCoding, forKey: cacheKey)
            }
        }
    }
    
    func packagingResponseObj(responseObj: AnyObject, responseModel: WXResponseModel) -> Dictionary<String, Any> {
        let config = WXNetworkConfig.shared
        var responseDcit: [String : Any] = [:]
        
        if responseObj is Dictionary<String, Any> {
            responseDcit += responseObj as! Dictionary<String, Any>
            
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
                //responseDcit[config.customModelKeyPath] = [responseObj description];
            }
            //只要返回为非Error就包装一个公共的key, 防止页面当失败解析
            if responseDcit[config.statusKey] == nil {
                responseDcit[config.statusKey] = "\(config.statusCode)"
            }
        }
        return responseDcit
    }

    
}
