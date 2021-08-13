//
//  WXFrameDefiner.swift
//  Manga
//
//  Created by 610582 on 2021/8/13.
//
// 存放公共尺寸相关变量

import Foundation
import UIKit

///屏幕宽度
let kScreenWidth = UIScreen.main.bounds.width

///屏幕高度
let kScreenHeight = UIScreen.main.bounds.height

///屏幕窗口安全区域
fileprivate func deviceSafeAreaInsets() -> UIEdgeInsets {
    if #available(iOS 11, *) {
        return UIApplication.shared.delegate?.window??.safeAreaInsets ?? .zero
    } else {
        return .zero
    }
}

///是否为刘海屏
var isiPhoneXScreen: Bool {
    return deviceSafeAreaInsets().bottom > 0
}

///状态栏高度
var statusBarHeight: CGFloat {
    return UIApplication.shared.statusBarFrame.size.height
}

///导航栏栏高度
var navBarHeight: CGFloat {
    return appTopVC()?.navigationController?.navigationBar.frame.size.height ?? 44
}

/// 导航栏 + 状态栏 = 的总高度
var statusAddNavBarHeight: CGFloat {
    return statusBarHeight + navBarHeight
}

///系统TabBar栏高度
var tabBarHeight: CGFloat {
    return appTopVC()?.tabBarController?.tabBar.bounds.size.height ?? 49
}

///屏幕底部安全间距
var bottomSafeArea: CGFloat {
    return deviceSafeAreaInsets().bottom
}
