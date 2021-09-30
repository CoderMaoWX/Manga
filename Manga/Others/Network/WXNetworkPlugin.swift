//
//  WXNetworkPlugin.swift
//  Manga
//
//  Created by 610582 on 2021/8/21.
//

import Foundation
import UIKit

class WXNetworkPlugin {
    
    /// 上传网络日志到服装日志系统入口 (目前此方法供内部使用)
    /// - Parameters:
    ///   - request: 响应模型
    ///   - responseModel: 请求对象
    static func uploadNetworkResponseJson(request: WXRequestApi,
                                   responseModel: WXResponseModel) {
        if responseModel.isCacheData { return }
        let configu = WXNetworkConfig.shared
        if configu.isDistributionOnlineRelease { return }
        
        guard let uploadLogUrl = configu.uploadRequestLogToURL, let _ = URL(string: uploadLogUrl) else { return }
        
        guard let catchLogTag = configu.uploadCatchLogTagFlag, catchLogTag.count > 0 else { return }
        
        var requestJson = request.finalParameters
        
        if let _ = request.finalParameters?[KWXUploadAppsFlyerStatisticsKey] {
            guard configu.printfStatisticsLog else { return }
            requestJson?.removeValue(forKey: KWXUploadAppsFlyerStatisticsKey)
        }
        
        let bundleInfo = Bundle.main.infoDictionary
        let appName = bundleInfo?[kCFBundleExecutableKey as String] ?? bundleInfo?[kCFBundleIdentifierKey as String] ?? ""
        
        let version = bundleInfo?["CFBundleShortVersionString"] ?? bundleInfo?[kCFBundleVersionKey as String] ?? ""
        
        let formatter = DateFormatter(format: "yyyy-MM-dd-HHmmssSSS")
        formatter.timeZone = NSTimeZone.local
        
        let logHeader = appendingPrintfLogHeader(request: request, responseModel: responseModel)
        let logFooter = responseModel.responseDict?.toJSON()
        var body = logHeader + (logFooter ?? "")
        body = body.replacingOccurrences(of: "\n", with: "<br>")
        
        var uploadInfo: Dictionary<String, Any> = [:]
        uploadInfo["level"]            = "iOS"
        uploadInfo["appName"]          = appName
        uploadInfo["version"]          = version
        uploadInfo["body"]             = body
        uploadInfo["platform"]         = "\(appName)-iOS-\(catchLogTag)"
        uploadInfo["device"]           = UIDevice.current.model
        uploadInfo["feeTime"]          = "\(responseModel.responseDuration ?? 0)"
        uploadInfo["timestamp"]        = formatter.string(from: Date())
        uploadInfo["url"]              = request.requestURL
        uploadInfo["request"]          = requestJson
        uploadInfo["requestHeader"]    = responseModel.urlRequest?.allHTTPHeaderFields ?? [:]
        uploadInfo["response"]         = responseModel.responseDict ?? [:]
        uploadInfo["responseHeader"]   = responseModel.urlResponse?.allHeaderFields ?? [:]
        
        let baseRequest = WXBaseRequest(uploadLogUrl, method: .post, parameters: uploadInfo)
        baseRequest.baseRequestBlock(successClosure: nil, failureClosure: nil)
    }


    /// 打印日志头部
    /// - Parameters:
    ///   - request: 响应模型
    ///   - responseModel: 请求对象
    /// - Returns: 日志头部字符串
    static func appendingPrintfLogHeader(request: WXRequestApi,
                                  responseModel: WXResponseModel) -> String {
        let isSuccess   = (responseModel.responseDict == nil) ? false : true
        let isCacheData = responseModel.isCacheData
        let requestJson = (request.finalParameters ?? [:]).toJSON() ?? ""
        let hostTitle = WXNetworkConfig.shared.networkHostTitle ?? ""
        let requestHeaders = responseModel.urlRequest?.allHTTPHeaderFields ?? [:]
        let headersString = (requestHeaders.count > 0) ? "\n\n请求头信息= \(requestHeaders.toJSON()!)" : ""
        let statusFlag = isCacheData ? "❤️❤️❤️" : (isSuccess ? "✅✅✅" : "❌❌❌")
        let dataType = responseModel.isTestResponse ? "测试数据" : "网络数据"
        let statusString  = isCacheData ? "本地缓存数据成功" : (isSuccess ? "\(dataType)成功" : "\(dataType)失败");
		return """

			\(statusFlag)请求接口地址\(hostTitle)= \(request.requestURL)

			请求参数json= \(requestJson)\(headersString)

			\(statusString)返回=

			"""
    }


    /// 打印日志尾部
    /// - Parameter responseModel: 响应模型
    /// - Returns: 日志头部字符串
    static func appendingPrintfLogFooter(responseModel: WXResponseModel) -> String {
        if let responseDict = responseModel.responseDict {
            let jsonData = try? JSONSerialization.data(withJSONObject: responseDict, options: .prettyPrinted)
            
            var responseJson = responseDict.description
            if let jsonData = jsonData {
                responseJson = String(data: jsonData, encoding: .utf8) ?? responseJson
            }
            return responseJson
        } else {
            return responseModel.error?.description ?? ""
        }
    }

    ///上传时获取图片类型
    static func fileMimeType(for data: Data) -> (type: String, name: String) {
        var b: UInt8 = 0
        data.copyBytes(to: &b, count: 1)

        switch b {
        case 0xFF:
            return ("image", "jpeg")
        case 0x89:
            return ("image", "png")
        case 0x47:
            return ("image", "gif")
        case 0x4D, 0x49:
            return ("image", "tiff")
        case 0x25:
            return ("application", "pdf")
        case 0xD0:
            return ("application", "vnd")
        case 0x46:
            return ("text", "file")
        default:
            return ("application", "stream")
        }
    }
}

