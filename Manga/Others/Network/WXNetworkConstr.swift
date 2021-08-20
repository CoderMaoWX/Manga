//
//  WXNetworkConstr.swift
//  Manga
//
//  Created by 610582 on 2021/8/20.
//

import Foundation

let KWXRequestFailueTipMessage = "Loading failed, please try again later."
let kWXRequestDataFromCacheKey = "WXNetwork_DataFromCacheKey"

protocol WXNetworkMulticenter {
    
    /// 网络请求将要开始回调
    /// - Parameter request: 请求对象
    func requestWillStart(request: WXNetworkRequest)
    
    
    /// 网络请求回调将要停止 (包括成功或失败)
    /// - Parameters:
    ///   - request: 请求对象
    ///   - responseModel: 响应对象
    func requestWillStop(request: WXNetworkRequest, responseModel: WXResponseModel)
    
    
    /// 网络请求已经回调完成 (包括成功或失败)
    /// - Parameters:
    ///   - request: 请求对象
    ///   - responseModel: 响应对象
    func requestDidCompletion(request: WXNetworkRequest, responseModel: WXResponseModel)
    
}


protocol WXNetworkDelegate {
    
    /// 网络请求数据响应回调
    /// - Parameters:
    ///   - request: 请求对象
    ///   - responseModel: 响应对象
    func wxResponseWithRequest(request: WXNetworkRequest, responseModel: WXResponseModel)
}
