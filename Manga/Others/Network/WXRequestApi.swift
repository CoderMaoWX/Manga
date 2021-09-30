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

typealias DictionaryStrAny = Dictionary<String, Any>


//MARK: - 请求基础对象

///请求基础对象, 外部上不建议直接用，请使用子类请求方法
typealias WXNetworkResponseBlock = (WXResponseModel) -> ()

class WXBaseRequest: NSObject {
    ///请求Method类型
    private (set) var requestMethod: HTTPMethod = .post
    ///请求地址
    private (set) var requestURL: String = ""
    ///请求参数
    private (set) var parameters: DictionaryStrAny? = nil
    ///请求超时，默认30s
    var timeOut: TimeInterval = 30
    ///请求自定义头信息
    var requestHeaderDict: Dictionary<String, String>? = nil
    ///请求任务对象
    private (set) var requestDataTask: DataRequest? = nil
    
    required init(_ requestURL: String, method: HTTPMethod = .post, parameters: DictionaryStrAny? = nil) {
        super.init()
        self.requestMethod = method
        self.requestURL = requestURL
        self.parameters = parameters
    }
    
    ///底层最终的请求参数 (页面上可实现<WXPackParameters>协议来实现重新包装请求参数)
    lazy var finalParameters: DictionaryStrAny? = {
        var parameters = parameters
        if conforms(to: WXPackParameters.self) {
            parameters = (self as? WXPackParameters)?.parametersWillTransformFromOriginParamete(parameters: parameters)
        }
        return parameters
    }()
    
    /// 网络请求方法 (不做任何额外处理的原始Alamofire请求，页面上不建议直接用，请使用子类请求方法)
    /// - Parameters:
    ///   - successClosure: 请求成功回调
    ///   - failureClosure: 请求失败回调
    /// - Returns: 求Session对象
    @discardableResult
    func baseRequestBlock(successClosure: ((AnyObject) -> ())?,
                          failureClosure: ((AnyObject) -> ())? ) -> DataRequest {
        let dataRequest = AF.request(requestURL,
                                     method: requestMethod,
                                     parameters: finalParameters,
                                     headers: HTTPHeaders(requestHeaderDict ?? [:]),
                                     requestModifier: {
                                        $0.timeoutInterval = self.timeOut
                                        $0.cachePolicy = .reloadIgnoringLocalCacheData
                                     }).responseJSON { response in

								switch response.result {
								case .success(let json):
									successClosure?(json as AnyObject)

								case .failure(let error):
									failureClosure?(error as AnyObject)
								}
						  }
        requestDataTask = dataRequest
        return dataRequest
    }
}

//MARK: - 单个请求对象

/// 单个请求对象, 功能根据需求可多种自定义
class WXRequestApi: WXBaseRequest {
    
    ///请求成功时是否自动缓存响应数据, 默认不缓存
    var autoCacheResponse: Bool = false
    
    ///自定义请求成功时的缓存数据, (返回的字典为此次需要保存的缓存数据, 返回nil时底层则不缓存)
    var cacheResponseBlock: ((WXResponseModel) -> (DictionaryStrAny?))? = nil
    
    ///自定义请求成功映射Key/Value, (key可以是KeyPath模式进行匹配 如: data.status)
	///注意: 每个请求成功状态优先使用此Map判断, 如果此值为空, 则再取 WXNetworkConfig.successKeyValueMap的值进行判断
    var successKeyValueMap: [String : String]? = nil
    
    ///请求成功时解析数据模型映射:KeyPath/Model: (支持KeyPath匹配, 解析的模型在 WXResponseModel.parseKeyPathModel 返回
    var parseKeyPathMap: [String : Convertible.Type]? = nil
    
    ///调试响应json/Dictionary,方便测试时使用, 如果有设置该值则不会请求,直接回调此值
    var testResponseJson: Any? = nil

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
    fileprivate var requestDuration: Double = 0
    fileprivate lazy var apiUniquelyIp: String = {
        return "\(self)"
    }()
    
    required init(_ requestURL: String, method: HTTPMethod = .post, parameters: DictionaryStrAny? = nil) {
        super.init(requestURL, method: method, parameters: parameters)
    }
    
    /// 开始网络请求
    /// - Parameter responseBlock: 请求回调
    /// - Returns: 请求任务对象(可用来取消任务)
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
        if var rspJsonDict = responseForTestjSon() {
            rspJsonDict[ kWXNetworkIsTestResponseKey ] = true
            networkBlock(rspJsonDict as AnyObject)
            return nil
        }
        handleMulticenter(type: .WillStart, responseModel: WXResponseModel())
        //开始请求
        let dataRequest = baseRequestBlock(successClosure: networkBlock, failureClosure: networkBlock)
        
        if WXNetworkConfig.shared.printfURLResponseLog {
            if retryCount == 0 {
                debugLog("👉👉👉已发出网络请求=", requestURL)
            } else {
                debugLog("👉👉👉请求失败,第 \(retryCount) 次尝试重新请求=", requestURL)
            }
        }
        return dataRequest
    }
    
    func responseForTestjSon() -> DictionaryStrAny? {
        if let rspJsonDict = testResponseJson as? DictionaryStrAny {
            return rspJsonDict
            
        } else if let rspJsonString = testResponseJson as? String {
            // jsonString -> Dictionary
            let data = rspJsonString.data(using: String.Encoding.utf8)
            if let rspJsonDict = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? DictionaryStrAny {
                return rspJsonDict
            }
        }
        return nil
    }
    
    fileprivate func configResponseBlock(responseBlock: @escaping WXNetworkResponseBlock, responseObj: AnyObject?) {
        
        let handleResponseClosure = { (responseObj: AnyObject?) in
            let responseModel = self.configResponseModel(responseObj: responseObj)
            responseBlock(responseModel)
            self.handleMulticenter(type: .DidCompletion, responseModel: responseModel)
        }
        if let retryCountWhenFail = retryCountWhenFail,
           retryCount < retryCountWhenFail,
           let error = responseObj as? Error, error._code != -999 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.retryCount += 1
                handleResponseClosure(responseObj)
                self.startRequest(responseBlock: responseBlock)
            }
            return
        }
        handleResponseClosure(responseObj)
    }
    
    ///寻找匹配请求成功的关键字典
    fileprivate func findAppositeDict(matchKey: String, respValue: Any?) -> Any? {
        if let respDict = respValue as? DictionaryStrAny {
            for (dictKey, dictValue) in respDict {
                if matchKey == dictKey {
                    return dictValue
                }
            }
        }
        return nil
    }

	///检查请求成功状态
	fileprivate func checkingSuccessStatus(responseDict: DictionaryStrAny, rspModel: WXResponseModel) -> Bool {
		var hasMapSuccess = false

		if let successKeyValue = self.successKeyValueMap ?? WXNetworkConfig.shared.successKeyValueMap, successKeyValue.count == 1 {

			let matchKey: String = successKeyValue.keys.first!
			let mapSuccessValue: String = successKeyValue.values.first!

			//1.如果包含点(.)连接,则采用KeyPath模式匹配查找请求成功标识
			if matchKey.contains(".") {
				var lastMatchValue: Any? = responseDict

				for tmpKey in matchKey.components(separatedBy: ".") {
					if lastMatchValue == nil {
						break
					} else { //寻找匹配请求成功的关键字典
						lastMatchValue = findAppositeDict(matchKey: tmpKey, respValue: lastMatchValue)
					}
				}
				//寻找匹配请求成功的关键key
				if lastMatchValue is String, (lastMatchValue as! String) == mapSuccessValue {
					hasMapSuccess = true
					rspModel.isSuccess = true
					rspModel.responseCode = Int(lastMatchValue as! String)

				} else if lastMatchValue is Int, (lastMatchValue as! Int) == Int(mapSuccessValue) {
					hasMapSuccess = true
					rspModel.isSuccess = true
					rspModel.responseCode = lastMatchValue as? Int
				}

			} else if let responseCode = responseDict[matchKey] {
				//2.采用直接查找匹配请求成功标识
				if responseCode is String, (responseCode as! String) == mapSuccessValue {
					hasMapSuccess = true
					rspModel.isSuccess = true
					rspModel.responseCode = Int(responseCode as! String)

				} else if responseCode is Int, (responseCode as! Int) == Int(mapSuccessValue) {
					hasMapSuccess = true
					rspModel.isSuccess = true
					rspModel.responseCode = responseCode as? Int
				}
			}
		}
		return hasMapSuccess
	}

	///配置数据响应回调模型
    fileprivate func configResponseModel(responseObj: AnyObject?) -> WXResponseModel {
        let rspModel = WXResponseModel()
        rspModel.responseDuration = getCurrentTimestamp() - self.requestDuration
        rspModel.apiUniquelyIp = apiUniquelyIp
        rspModel.responseObject = responseObj
        
        rspModel.urlRequest = requestDataTask?.request
        rspModel.urlResponse = requestDataTask?.response

        var code: Int? = nil
        var domain: String = configFailMessage
        if let error = responseObj as? Error {
            code = error._code
            domain = error._domain
        } else if let error = responseObj as? NSError {
            code = error.code
            domain = error.domain
        } else if responseObj == nil {
            code = -444
        }
        
        if let errorCode = code { // Fail
            rspModel.responseMsg = domain
            rspModel.responseCode = errorCode
            rspModel.error = NSError(domain: domain, code: errorCode, userInfo: nil)
            
        } else { //Success
            let responseDict = packagingResponseObj(responseObj: responseObj!, responseModel: rspModel)
            rspModel.responseDict = responseDict
            
            let hasMapSuccess = checkingSuccessStatus(responseDict: responseDict, rspModel: rspModel)

            if rspModel.isSuccess {
                rspModel.parseResponseKeyPathModel(requestApi: self, responseDict: responseDict)
                
            } else if hasMapSuccess {
                if let msgTipKeyOrFailInfo = WXNetworkConfig.shared.messageTipKeyAndFailInfo, msgTipKeyOrFailInfo.count == 1  {
                    if let msg = responseDict[ (msgTipKeyOrFailInfo.keys.first!) ] {
                        rspModel.responseMsg = msg as? String
                    } else {
                        rspModel.responseMsg = msgTipKeyOrFailInfo.values.first ?? configFailMessage
                    }
                }
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
    
    fileprivate func packagingResponseObj(responseObj: AnyObject, responseModel: WXResponseModel) -> DictionaryStrAny {
        var responseDcit: [String : Any] = [:]
        if responseObj is DictionaryStrAny {
            responseDcit += responseObj as! DictionaryStrAny
            
            responseDcit[ kWXNetworkIsTestResponseKey ].map({
                responseDcit.removeValue(forKey: kWXNetworkIsTestResponseKey)
                responseModel.isTestResponse = $0 as! Bool
            })
            if let _ = responseDcit[kWXRequestDataFromCacheKey] {
                responseDcit.removeValue(forKey: kWXRequestDataFromCacheKey)
                responseModel.isCacheData = true
            }
        } else if responseObj is Data {
            let rspData = responseObj.mutableCopy()
            if let rspData = rspData as? Data {
                responseModel.responseObject = rspData as AnyObject
            }
        } else if let jsonString = responseObj as? String { // jsonString -> Dictionary
            if let jsonDict = (try? JSONSerialization.jsonObject( with: jsonString.data(using: String.Encoding.utf8, allowLossyConversion: true)!, options: JSONSerialization.ReadingOptions.mutableContainers)) as? DictionaryStrAny {
                return jsonDict
            } else {
                responseDcit["response"] = jsonString
            }
        } else if let response = responseObj.description {
            responseDcit["response"] = response
        }
        return responseDcit
    }
    
    ///网络请求过程多链路回调
    fileprivate func handleMulticenter(type: WXRequestMulticenterType,
                                       responseModel: WXResponseModel) {
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
            // save cache as much as possible at the end
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
        guard WXNetworkConfig.shared.printfURLResponseLog else { return }
        let logHeader = WXNetworkPlugin.appendingPrintfLogHeader(request: self, responseModel: responseModel)
        let logFooter = WXNetworkPlugin.appendingPrintfLogFooter(responseModel: responseModel)
        debugLog("\(logHeader + logFooter)")
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
                guard let cacheObject = cacheObject, var cacheDcit = cacheObject as? DictionaryStrAny else { return }
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
            if let responseObject = responseModel.responseObject, responseObject is DictionaryStrAny {
                let networkCache = WXNetworkConfig.shared.networkDiskCache
                networkCache.setObject(responseObject as? NSCoding, forKey: cacheKey)
            }
        }
    }
    
}

//MARK: - 批量请求对象

///批量请求对象, 可以
class WXBatchRequestApi {
    
    ///全部请求是否都成功了
    var isAllSuccess: Bool = false
    
    ///全部响应数据, 按请求requestArray的添加顺序排序
    var responseDataArray: [WXResponseModel] = []
    
    ///全部请求对象, 响应时按添加顺序返回
    fileprivate (set) var requestArray: [WXRequestApi]
    
    fileprivate var requestCount: Int = 0
    fileprivate var hasMarkBatchFail: Bool = false
    fileprivate var batchRequest: WXBatchRequestApi? = nil //避免提前释放当前对象
    fileprivate var responseBatchBlock: ((WXBatchRequestApi) -> ())? = nil
    fileprivate var responseInfoDict: Dictionary<String, WXResponseModel> = [:]
    
    required init(requestArray: [WXRequestApi]) {
        self.requestArray = requestArray
    }
    
    ///根据请求获取指定的响应数据
    func responseForRequest(request: WXRequestApi) -> WXResponseModel {
        return responseInfoDict[request.apiUniquelyIp] ?? WXResponseModel()
    }
    
    /// 批量网络请求: (实例方法:Block回调方式)
    /// - Parameters:
    ///   - responseBlock: 请求全部完成后的响应block回调
    ///   - waitAllDone: 是否等待全部请求完成才回调, 否则回调多次
    func startRequest(_ responseBlock: @escaping (WXBatchRequestApi) -> (),
                      waitAllDone: Bool = true) {
        
        responseDataArray.removeAll()
        requestCount = requestArray.count
        hasMarkBatchFail = false
        batchRequest = self
        responseBatchBlock = responseBlock
        for api in requestArray {
            
            api.startRequest { responseModel in
                if responseModel.responseDict == nil {
                    self.hasMarkBatchFail = true
                }
                if waitAllDone {
                    self.finalHandleBatchResponse(responseModel: responseModel)
                } else { //回调多次
                    self.oftenHandleBatchResponse(responseModel: responseModel)
                }
            }
        }
    }
    
    ///待所有请求都响应才回调到页面
    fileprivate func finalHandleBatchResponse(responseModel: WXResponseModel) {
        let apiUniquelyIp = responseModel.apiUniquelyIp
        
        //本地有缓存, 当前请求失败了就不保存当前失败RspModel,则使用用缓存
        if self.responseInfoDict[apiUniquelyIp] == nil || responseModel.responseDict != nil {
            self.responseInfoDict[apiUniquelyIp] = responseModel
        }
        if responseModel.isCacheData == false {
            requestCount -= 1
        }
        guard requestCount <= 0 else { return }
        
        isAllSuccess = !hasMarkBatchFail
        
        // 请求最终回调
        responseDataArray = requestArray.compactMap {
            responseInfoDict[ $0.apiUniquelyIp ]
        }
        if let responseBatchBlock = responseBatchBlock {
            responseBatchBlock(self)
        }
        batchRequest = nil
    }
    
    ///每次请求响应都回调到页面
    fileprivate func oftenHandleBatchResponse(responseModel: WXResponseModel) {
        
        //本地有缓存, 当前请求失败了就不保存当前失败RspModel,则使用用缓存
        let apiUniquelyIp = responseModel.apiUniquelyIp
        if responseInfoDict[apiUniquelyIp] == nil || responseModel.responseDict != nil {
            responseInfoDict[apiUniquelyIp] = responseModel
        }
        if responseModel.isCacheData == false {
            isAllSuccess = !hasMarkBatchFail
        }
        ///按请求对象添加顺序排序
        let tmpRspArray = responseInfoDict.allValues()
        var finalRspArray: [WXResponseModel] = []
        for request in requestArray {
            for response in tmpRspArray {
                if request.apiUniquelyIp == response.apiUniquelyIp {
                    finalRspArray.append(response)
                    break
                }
            }
        }
        if finalRspArray.count > 0 {
            responseDataArray.removeAll()
            responseDataArray += finalRspArray
            if let responseBatchBlock = responseBatchBlock {
                responseBatchBlock(self)
            }
        }
        if requestCount >= responseDataArray.count {
            batchRequest = nil
        }
    }
    
    /// 取消所有请求
    func cancelAllRequest() {
        for request in requestArray {
            request.requestDataTask?.cancel()
        }
    }
    
}

//MARK: - 请求响应对象

///包装的响应数据
class WXResponseModel: NSObject {
    /**
     * 是否请求成功,优先使用 WXRequestApi.successKeyValueMap 来判断是否成功
     * 否则使用 WXNetworkConfig.successKeyValueMap 标识来判断是否请求成功
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
    ///本次响应的原始数据: NSDictionary/ UIImage/ NSData /...
    var responseObject: AnyObject? = nil
    ///本次响应的原始字典数据
    var responseDict: DictionaryStrAny? = nil
    ///本次响应的数据是否是测试数据
    var isTestResponse: Bool = false
    ///失败时的错误信息
    var error: NSError? = nil
    ///原始响应
    var urlResponse: HTTPURLResponse? = nil
    ///原始请求
    var urlRequest: URLRequest? = nil
    
    fileprivate (set) var apiUniquelyIp: String = "\(String(describing: self))"
    
    ///解析响应数据的数据模型 (支持KeyPath匹配)
    fileprivate func parseResponseKeyPathModel(requestApi: WXRequestApi,
                                               responseDict: DictionaryStrAny) {
        guard let keyPathInfo = requestApi.parseKeyPathMap, keyPathInfo.count == 1 else { return }
        
        let parseKey: String = keyPathInfo.keys.first!
        guard parseKey.count > 0 else { return }
        let parseCalss = keyPathInfo.values.first
        guard let modelCalss = parseCalss else { return }
        
        var lastValueDict: Any?
        if parseKey.contains(".") {
            let keyPathArr = parseKey.components(separatedBy: ".")
            lastValueDict = responseDict
            
            for modelKey in keyPathArr {
                if lastValueDict == nil {
                    return
                } else {
                    lastValueDict = findParseDict(respKey: modelKey, respValue: lastValueDict)
                }
            }
        } else {
            lastValueDict = responseDict[parseKey]
        }
        if let customModelValue = lastValueDict as? DictionaryStrAny {
            parseKeyPathModel = customModelValue.kj.model(type: modelCalss) as AnyObject
            
        }  else if let modelObj = lastValueDict as? Array<Any> {
            parseKeyPathModel = modelObj.kj.modelArray(type: modelCalss) as AnyObject
        }
    }

    ///寻找最合适的解析: 字典/数组
    fileprivate func findParseDict(respKey: String, respValue: Any?) -> Any? {
        if let respDict = respValue as? DictionaryStrAny {
            for (dictKey, dictValue) in respDict {
                if respKey == dictKey {
                    return dictValue
                }
            }
        }
        return nil
    }
    
}
