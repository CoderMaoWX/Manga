//
//  DeeplinkManager.swift
//  Manga
//
//  Created by 610582 on 2022/1/6.
//

import Foundation
import KakaJSON

enum DeeplinkActionType: Int, ConvertibleEnum {
    case jump_Default = 0
    case jump_Home = 1
    case jump_Detail = 2
}

struct DeeplinkModel: Convertible {
    var action: DeeplinkActionType = .jump_Default;
    var url: String = ""
    var name: String? = ""
}

/**
 * 跳转Deeplink例子：Manga://open?params=%7B%22m_param%22%20%3A%20%7B%7D%2C%20%22source%22%3A%22%22%2C%22url%22%20%3A%20%22100004293741%22%2C%22action%22%20%3A%20%221%22%2C%22name%22%3A%22%22%7D
 * 注意：参数为json数据必须使用URL encode编码(请使用encodeURIComponent编码方式)，需要将特殊字符全部编码，编码URL工具：http://www.bejson.com/enc/urlencode/
 * 1.如果是Manga开头: 就用deeplink打开,
 * 2.http/https开头 :则打开webVC
*/
func OpenWXDeeplink(url: String?, title: String?) {
    guard var url = url, url.isEmpty == false else { return }
    url = url.trimmingCharacters(in: .whitespacesAndNewlines)
    
    if url.hasPrefix("\(kAppURLSchemes):") {
        let params = "params="
        guard url.contains(params) else { return }
        
        if let allJson = url.components(separatedBy: params).last, let paramsJson = allJson.removingPercentEncoding {
            debugLog("Deeplink的解析参数: params=\(paramsJson)")
            
            if var model = paramsJson.kj.model(type: DeeplinkModel.self) as? DeeplinkModel {
                if model.name?.isEmpty == true {
                    model.name = title
                }
                jumpDeeplinkWithModel(jumpModel: model)
            }
        }
    } else if url.hasPrefix("http") {
        let webVC = WebVC(url: url)
        webVC.title = title
        
        let currentVC = appTopVC
        if let currentNav = currentVC?.navigationController {
            currentNav.pushViewController(webVC, animated: true)
            
        } else if let _ = currentVC?.presentingViewController {
            currentVC?.modalPresentationStyle = .fullScreen
            currentVC?.present(webVC, animated: true, completion: nil)
        }
    }
}

///跳转页面类型 (deeplink文档: xxxx)
private func jumpDeeplinkWithModel(jumpModel: DeeplinkModel) {
    debugLog("Deeplink跳转类型: action=\(jumpModel.action), url=\(jumpModel.url), name=\(jumpModel.name ?? "")")
    
    let currentVC = appTopVC
    switch jumpModel.action {
        
    case .jump_Default:
        debugLog("do nothing")
        break
        
    case .jump_Home:
        
        let selectTabBarBlock = {
            if let tabBarVC = appTopVC?.view.window?.rootViewController as? UITabBarController {
                tabBarVC.selectedIndex = 0
            }
        }
        if let currentNav = currentVC?.navigationController {
            currentNav.popToRootViewController(animated: true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                selectTabBarBlock()
            }
        } else if let _ = currentVC?.presentingViewController {
            currentVC?.dismiss(animated: true, completion: {
                selectTabBarBlock()
            })
        }
        break
        
    default:
        break
    }
}
