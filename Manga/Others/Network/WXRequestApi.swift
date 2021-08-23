//
//  WXRequestApi.swift
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

///包装的响应数据
class WXResponseModel: NSObject {
    /**
     * 是否请求成功
     * 优先使用 WXRequestApi.successKeyCodeMap,
     * 否则使用WXNetworkConfig.successKeyCodeMap标识来判断是否请求成功
     ***/
    var isSuccess: Bool = false
    ///本次响应Code码
    var responseCode: Int? = nil
    ///本次响应的提示信息
    var responseMsg: String? = nil
    ///本次数据是否为缓存
    var isCacheData: Bool = false
    ///请求耗时(毫秒)
    var responseDuration: TimeInterval? = nil
    ///解析数据的模型: 可KeyPath匹配, 返回 Model对象 或者数组模型 [Model]
    var parseKeyPathModel: AnyObject? = nil
    ///本次响应的原始数据: NSDictionary, UIImage, NSData ...
    var responseObject: AnyObject? = nil
    ///本次响应的字典数据
    var responseDict: Dictionary<String, Any>? = nil
    ///错误信息
    var error: NSError? = nil
    ///原始响应
    var urlResponse: HTTPURLResponse? = nil
    ///原始请求
    var urlRequest: URLRequest? = nil
    
    fileprivate (set) var apiUniquelyIp: String?  = nil
    
    ///解析响应数据的数据模型 (支持KeyPath匹配)
    fileprivate func parseResponseKeyPathModel(requestApi: WXRequestApi,
                                                  responseDict: Dictionary<String, Any>) {
        guard let keyPathInfo = requestApi.parseKeyPathMap, keyPathInfo.count == 1 else { return }
        
        let parseKey: String = keyPathInfo.keys.first!
        guard parseKey.count > 0 else { return }
        let parseCalss = keyPathInfo.values.first
        guard let modelCalss = parseCalss else { return }
        
        var lastValueDict: Any?
        if parseKey.contains(".") {
            let keyPathArr =  parseKey.components(separatedBy: ".")
            lastValueDict = responseDict
            
            for modelKey in keyPathArr {
                if lastValueDict == nil {
                    return
                } else {
                    lastValueDict = findSuitableDict(respKey: modelKey, respValue: lastValueDict)
                }
            }
        } else {
            lastValueDict = responseDict[parseKey]
        }
        if let customModelValue = lastValueDict as? Dictionary<String, Any> {
            parseKeyPathModel = customModelValue.kj.model(type: modelCalss) as AnyObject
            
        }  else if let modelObj = lastValueDict as? Array<Any> {
            parseKeyPathModel = modelObj.kj.modelArray(type: modelCalss) as AnyObject
        }
    }

    ///寻找最合适的解析: 字典/数组
    fileprivate func findSuitableDict(respKey: String, respValue: Any?) -> Any? {
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
    private (set) var requestDataTask: DataRequest? = nil
    
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

typealias WXCacheResponseClosure = (WXResponseModel) -> (Dictionary<String, Any>?)

class WXRequestApi: WXBaseRequest {
    
    ///请求成功时是否自动缓存响应数据, 默认不缓存
    var autoCacheResponse: Bool = false
    
    ///请求成功时自定义响应缓存数据, (返回的字典为此次需要保存的缓存数据, 返回nil时,底层则不缓存)
    var cacheResponseBlock: WXCacheResponseClosure? = nil
    
    ///自定义请求成功映射Key/Value
    var successKeyCodeMap: [String : Int]? = nil
    
    ///请求成功时解析数据模型映射:KeyPath/Model: (支持KeyPath匹配, 解析的模型在 WXResponseModel.parseKeyPathModel 返回
    var parseKeyPathMap: [String : Convertible.Type]? = nil

    ///请求转圈的父视图
    var loadingSuperView: UIView? = nil
    
    ///请求失败之后重新请求次数, (每次重试时间隔3秒)
    var retryCountWhenFail: Int? = nil
    
    ///网络请求过程多链路回调<将要开始, 将要停止, 已经完成>
    /// 注意: 如果没有实现此代理则会回调单例中的全局代理<globleMulticenterDelegate>
    var multicenterDelegate: WXNetworkMulticenter? = nil
    
    ///可以用来添加几个accossories对象 来做额外的插件等特殊功能
    ///如: (请求HUD, 加解密, 自定义打印, 上传统计)
    var requestAccessories: [WXNetworkMulticenter]? = nil
    
    ///以下为私有属性,外部可以忽略
    fileprivate var retryCount: Int = 0
    fileprivate var apiUniquelyIp: String = ""
    fileprivate var requestDuration: Double = 0
    
    @discardableResult
    func startRequest(responseBlock: @escaping WXNetworkResponseBlock) -> DataRequest? {
        guard let _ = URL(string: requestURL) else {
            debugLog("\n❌❌❌无效的 URL 请求地址= \(requestURL)")
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
        //开始请求
        let dataRequest = baseRequestBlock(successClosure: networkBlock, failureClosure: networkBlock)
        
        if WXNetworkConfig.shared.closeUrlResponsePrintfLog == false {
            if retryCount == 0 {
                debugLog("\n👉👉👉已发出网络请求=", requestURL)
            } else {
                debugLog("\n👉👉👉请求失败,第 \(retryCount) 次尝试重新请求=", requestURL)
            }
        }
        return dataRequest
    }
    
    fileprivate func configResponseBlock(responseBlock: @escaping WXNetworkResponseBlock, responseObj: AnyObject?) {
        
        let handleResponseFn = { (responseObj: AnyObject?) in
            let responseModel = self.configResponseModel(responseObj: responseObj)
            responseBlock(responseModel)
            self.handleMulticenter(type: .DidCompletion, responseModel: responseModel)
        }
        
        if responseObj != nil {
            if let retryCountWhenFail = retryCountWhenFail,
               retryCount < retryCountWhenFail,
               let error = responseObj as? Error, error._code != -999 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.retryCount += 1
                    handleResponseFn(responseObj)
                    self.startRequest(responseBlock: responseBlock)
                }
                return
            }
        }
        handleResponseFn(responseObj)
    }
    
    ///配置数据响应回调模型
    fileprivate func configResponseModel(responseObj: AnyObject?) -> WXResponseModel {
        let rspModel = WXResponseModel()
        rspModel.responseDuration  = getCurrentTimestamp() - self.requestDuration
        rspModel.apiUniquelyIp     = apiUniquelyIp
        rspModel.responseObject    = responseObj
        
        rspModel.urlRequest = requestDataTask?.request
        rspModel.urlResponse = requestDataTask?.response

        var code: Int? = nil
        if let error = responseObj as? Error {
            code = error._code
        } else if let error = responseObj as? NSError {
            code = error.code
        } else if responseObj == nil {
            code = -444
        }
        if let errorCode = code { //has Error
            rspModel.responseMsg   = configFailMessage
            rspModel.responseCode  = errorCode
            rspModel.error = NSError(domain: configFailMessage, code: errorCode, userInfo: nil)
            
        } else {
            let responseDict = packagingResponseObj(responseObj: responseObj!, responseModel: rspModel)
            rspModel.responseDict = responseDict
            
            let config = WXNetworkConfig.shared
            if let successKeyCode = self.successKeyCodeMap ?? config.successKeyCodeMap, successKeyCode.count == 1 {
                let setKey: String = successKeyCode.keys.first!
                let setCode: Int = successKeyCode.values.first!
                
                if let responseCode = responseDict[setKey], let rspCode = responseCode as? Int {
                    rspModel.isSuccess = (setCode == rspCode)
                    rspModel.responseCode = rspCode
                }
            }
            if let msgTipKeyOrFailInfo = config.messageTipKeyAndFailInfo, msgTipKeyOrFailInfo.count == 1  {
                if let msg = responseDict[ (msgTipKeyOrFailInfo.keys.first!) ] {
                    rspModel.responseMsg = msg as? String
                } else {
                    rspModel.responseMsg = msgTipKeyOrFailInfo.values.first ?? configFailMessage
                }
            }
            if rspModel.isSuccess {
                rspModel.parseResponseKeyPathModel(requestApi: self, responseDict: responseDict)
            } else {
                let domain = rspModel.responseMsg ?? configFailMessage
                let code = rspModel.responseCode ?? -444
                rspModel.error = NSError(domain: domain, code: code, userInfo: responseDict)
            }
        }
        if rspModel.isCacheData == false {
            handleMulticenter(type: .WillStop, responseModel: rspModel)
        }
        return rspModel
    }
    
    ///网络请求过程多链路回调
    fileprivate func handleMulticenter(type: WXRequestMulticenterType, responseModel: WXResponseModel) {
        
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
            printfResponseLog(responseModel: responseModel)
            
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
            if responseModel.isCacheData {
                printfResponseLog(responseModel: responseModel)
            } else {
                saveResponseObjToCache(responseModel: responseModel)
            }
        }
    }
    
    ///打印网络响应日志到控制台
    fileprivate func printfResponseLog(responseModel: WXResponseModel) {
        #if DEBUG
        guard WXNetworkConfig.shared.closeUrlResponsePrintfLog == false else { return }
        let logHeader = WXNetworkPlugin.appendingPrintfLogHeader(request: self, responseModel: responseModel)
        let logFooter = WXNetworkPlugin.appendingPrintfLogFooter(responseModel: responseModel)
        debugLog("\(logHeader + logFooter)");
        #endif
    }
    
    ///检查是否需要发出通知
    fileprivate func checkPostNotification(responseModel: WXResponseModel) {
        let notifyDict = WXNetworkConfig.shared.codeNotifyDict
        if let responseCode = responseModel.responseCode, let notifyDict = notifyDict {
            for (key, value) in notifyDict where responseCode == value {
                NotificationCenter.default.post(name: NSNotification.Name(key), object: responseModel)
            }
        }
    }
    
    fileprivate func getCurrentTimestamp() -> Double {
        let dat = NSDate.init(timeIntervalSinceNow: 0)
        return dat.timeIntervalSince1970 * 1000
    }
    
    ///添加请求转圈
    fileprivate func judgeShowLoading(show: Bool) {
        guard WXNetworkConfig.shared.showRequestLaoding else { return }
        if let loadingSuperView = loadingSuperView {
            if show {
                showLoading(toView: loadingSuperView)
            } else {
                hideLoading(from: loadingSuperView)
            }
        }
    }
    
    ///失败默认提示
    fileprivate var configFailMessage: String {
        if let msgTipKeyOrFailInfo = WXNetworkConfig.shared.messageTipKeyAndFailInfo, msgTipKeyOrFailInfo.count == 1  {
            return msgTipKeyOrFailInfo.values.first ?? KWXRequestFailueTipMessage
        }
        return KWXRequestFailueTipMessage
    }
    
    //MARK: - DealWithCache
    
    lazy var cacheKey: String = {
        if cacheResponseBlock != nil || autoCacheResponse {
            return (requestURL + (finalParameters?.toJSON() ?? "") ).jk.md5Encrypt()
        }
        return ""
    }()
    
    ///检查接口本地需要有缓存
    fileprivate func checkRequestInCache() -> Bool {
        if cacheResponseBlock != nil || autoCacheResponse {
            let networkCache = WXNetworkConfig.shared.networkDiskCache
            if networkCache.containsObject(forKey: cacheKey) {
                return true
            }
        }
        return false
    }
    
    ///读取接口本地缓存数据
    fileprivate func readRequestCacheWithBlock(fetchCacheBlock: @escaping (AnyObject) -> ()) {
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
    
    ///保存接口响应数据到本地缓存
    fileprivate func saveResponseObjToCache(responseModel: WXResponseModel) {
        if let cacheBlock = cacheResponseBlock {
            let customResponseObject = cacheBlock(responseModel)
            if let saveCache = customResponseObject {
                let networkCache = WXNetworkConfig.shared.networkDiskCache
                networkCache.setObject(saveCache as NSCoding, forKey: cacheKey)
            }
        } else if autoCacheResponse {
            if let responseObject = responseModel.responseObject, responseObject is Dictionary<String, Any> {
                let networkCache = WXNetworkConfig.shared.networkDiskCache
                networkCache.setObject(responseObject as? NSCoding, forKey: cacheKey)
            }
        }
    }
    
    fileprivate func packagingResponseObj(responseObj: AnyObject, responseModel: WXResponseModel) -> Dictionary<String, Any> {
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
            }
            //只要返回为非Error就包装一个公共的key, 防止页面当失败解析
            // if let successKeyCode = self.successKeyCodeMap ?? config.successKeyCodeMap, successKeyCode.count == 1 {
            //     let setKey: String = successKeyCode.keys.first!
            //     let setCode: Int = successKeyCode.values.first!
            //     responseDcit[setKey] = "\(setCode)"
            // }
            
        } else if let jsonString = responseObj as? String { // jsonString -> Dictionary
            if let data = (try? JSONSerialization.jsonObject( with: jsonString.data(using: String.Encoding.utf8, allowLossyConversion: true)!, options: JSONSerialization.ReadingOptions.mutableContainers)) as? Dictionary<String, Any> {
                return data
            }
        } else if let response = responseObj.description {
            responseDcit["response"] = response
        }
        return responseDcit
    }
    
}


class WXBatchRequestApi {
    
    ///全部请求对象, 响应时按添加顺序返回
    var requestArray: [WXRequestApi]? = nil
    
    ///isAllDone
    fileprivate (set) var isAllDone: Bool = false
    
    ///全部响应数据,按请求Api的添加顺序返回
    var responseDataArray: [WXResponseModel]? = nil
    
    /// 取消所有请求
    func cancelAllRequest() {
        
    }
    
    typealias WXNetworkBatchBlock = (WXBatchRequestApi) -> ()
    
    
    /// 批量网络请求: (实例方法:Block回调方式)
    /// - Parameters:
    ///   - responseBlock: 请求全部完成后的响应block回调
    ///   - waitAllDone: 是否等待全部请求完成才回调, 否则回调多次
    func startRequest(responseBlock: WXNetworkBatchBlock, waitAllDone: Bool = true) {
        
        
        
    }
    
}
