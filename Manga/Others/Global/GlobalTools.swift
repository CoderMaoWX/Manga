//
//  GlobalTools.swift
//  WXSwiftDemo
//
//  Created by 610582 on 2021/8/2.
//

import Foundation
import UIKit
import CoreGraphics
import Kingfisher
import Alamofire

//============================ 给指定的类添加前缀来扩展方法 ============================

struct Manga<Base> {
    var base: Base
    init(_ base: Base) {
        self.base = base
    }
}

protocol MgCompatible {}
extension MgCompatible {
    var mg: Manga<Self> {
        get { Manga(self) }
        set {}
    }
    static var mg: Manga<Self>.Type {
        get { Manga.self }
        set {}
    }
}

//============================ 示例用法 ============================
/*
 extension String: MgCompatible {}
 
 extension Manga where Base == String {
     static func statusMethod() {
         debugLog("测试静态方法")
     }
     func instanceMethod() {
         debugLog("测试实例方法")
     }
     mutating func mutatingMethod() {
        debugLog("测试结构体,枚举修改实例内存的方法")
    }
 }
 
 func mangaTest() {
     "Manga".mg.instanceMethod()
     String.mg.statusMethod()
 }
 */


//MARK: =========== UIImageView扩展加载图片 ===========

/**
 * 给UIImageView扩展加载图片的前缀,方便在日后一键全部替换底层图片加载框架
 */
extension UIImageView: MgCompatible {}
extension Manga where Base: UIImageView {
    func setImageURL(_ with: String?) {
        let url = URL(string: with ?? "")
        base.kf.setImage(with: url)
    }
    
    func setImageURL(with: String?, placeholder: String = "") {
        let url = URL(string: with ?? "")
        base.kf.setImage(with: url, placeholder: UIImage(named: placeholder))
    }
}


//extension UIView: MgCompatible {}
//extension Manga where Base: UIView {
//
////    base.snp.makeConstraints {
////        $0.edges.equalTo(view)
////    }
//
//    func makeConstraints(_ closure: (_ make: ConstraintMaker) -> Void) {
//        base.snp.makeConstraints(closure)
//    }
//}


//MARK: =========== 扩展 ===========

//MARK: - 全局打印日志方法
func debugLog(_ message: Any...,
              file: String = #file,
              function: String = #function,
              lineNumber: Int = #line) {
    #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        //print("[\(fileName):funciton:\(function):line:\(lineNumber)]- \(message)")
    
        var appdengLog: String = ""
        var idx = message.count
        for log in message {
            appdengLog += "\(log)" + ( (idx != 1) ? " " : "" )
            idx -= 1
        }
        print("[\(fileName): line:\(lineNumber)]", appdengLog)
    #endif
}

///初始化网络监听器
let reachabilityNetwork: NetworkReachabilityManager? = {
    return NetworkReachabilityManager.init()
}()

///开启网络监听, 网络变化回调
func networkListen() {
    let status = reachabilityNetwork?.startListening(onUpdatePerforming: { status in
        switch status {
        case .reachable(.cellular):
            debugLog("主人,检测到您正在使用移动数据,请注意流量变化")
        
        case .notReachable:
            debugLog("主人,检测到您网络连接失败,请检查网络")
        
        default:
            debugLog("网络连接变化: \(status)")
            break
        }
    })
    debugLog("已开始监听网络: \(String(describing: status))")
}
