//
//  GlobalConst.swift
//  Manga
//
//  Created by 610582 on 2021/8/13.
//
// 存放公共宏变量

import Foundation
import UIKit

//MARK: - App信息相关

//App名称
let kAppDispalyName           = "App名称"

//App BundleID
let kAppBundleID              = "com.xxx.xxx"

//App Schemes
let kAppURLSchemes            = "Manga"

//警告:上线后修改成真正的AppStore中的Appid
let kAppStoreAppId            = "xxx"

//AppStore的下载地址
var kAppStoreDownloadURL: String {
    return "https://itunes.apple.com/us/app/zaful/id\(kAppStoreAppId)?ls=1&mt=8"
}


//MARK: - 通知相关


//MARK: - 常亮相关
let kToastShowTime            = 1.5
let kLoadingHUDTag            = 7987
let kLoadingViewKey           = "kLoadingViewKey"




//MARK: - ...
