//
//  GlobalUtils.swift
//  Manga
//
//  Created by 610582 on 2021/8/13.
//

import Foundation
import UIKit
import JKSwiftExtension

///获取成员变量
func namesOfMemberVaribale(cls: AnyClass) -> [String] {
    var resultArr: [String] = []
    var count: UInt32 = 0
    let ivars = class_copyIvarList(cls.self, &count)
    
    for i in 0 ..< count {
        let tmpIvar = ivars![Int(i)]
        let name = ivar_getName(tmpIvar)
        resultArr.append(String(cString: name!))
    }
    free(ivars)
    return resultArr
}

///获取类的属性名数组(只是声明property的成员变量)
func propertyNamesOfMember(cls: AnyClass) -> [String] {
    var resultArr: [String] = []
    var count: UInt32 = 0
    let propertys = class_copyPropertyList(cls.self, &count)
    
    for i in 0 ..< count {
        let tmpProperty = propertys![Int(i)]
        let name = property_getName(tmpProperty)
        resultArr.append(String(cString: name))
    }
    free(propertys)
    return resultArr
}

///获取App最顶层的控制器
func appTopVC() -> UIViewController? {
    let window = UIApplication.shared.keyWindow
    //当前windows的根控制器
    var controller = window?.rootViewController

    //通过循环一层一层往下查找
    while true {
        //先判断是否有present的控制器
        if (controller?.presentedViewController) != nil {
            //有的话直接拿到弹出控制器，省去多余的判断
            controller = controller?.presentedViewController
        } else {
            if controller is UINavigationController {
                //如果是NavigationController，取最后一个控制器（当前）
                controller = controller?.children.last
                
            } else if controller is UITabBarController {
                //如果TabBarController，取当前控制器
                let tabBarController = controller as! UITabBarController
                
                controller = tabBarController.selectedViewController
                
            } else if controller?.children.count ?? 0 > 0 {
                //如果是普通控制器，找childViewControllers最后一个
                controller = controller?.children.last
                
            } else {
                //没有present，没有childViewController，则表示当前控制器
                return controller
            }
        }
    }
}

/// 渐变方向
enum GradientChangeDirection: Int {
    case Horizontal          //水平渐变
    case Vertical            //竖直渐变
    case UpwardDiagonalLine  //向下对角线渐变
    case DownDiagonalLine    //向上对角线渐变
}

///获取渐变色
func gradientColor(size: CGSize,
                   direction: GradientChangeDirection,
                   startcolor: UIColor,
                   endColor: UIColor) -> UIColor? {
    if __CGSizeEqualToSize(size, .zero) {
        return nil
    }
    let gradient = CAGradientLayer()
    gradient.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    
    var startPoint = CGPoint.zero
    if direction == .DownDiagonalLine {
        startPoint = CGPoint(x: 0.0, y: 1.0)
    }
    gradient.startPoint = startPoint
    
    var endPoint = CGPoint.zero
    
    switch direction {
    case .Horizontal:
        endPoint = CGPoint(x: 1.0, y: 0.0)
        
    case .Vertical:
        endPoint = CGPoint(x: 0.0, y: 1.0)
        
    case .UpwardDiagonalLine:
        endPoint = CGPoint(x: 1.0, y: 1.0)
        
    case .DownDiagonalLine:
        endPoint = CGPoint(x: 1.0, y: 0.0)
    }
    
    gradient.endPoint = endPoint
    gradient.colors = [startcolor.cgColor, endColor.cgColor]
    
    UIGraphicsBeginImageContext(size)
    gradient.render(in: UIGraphicsGetCurrentContext()!)
    let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    let renderColor = UIColor.init(patternImage: image)
    return renderColor
}

/// 获取属性文字 (支持 图片,文字 混排)
/// - Parameters:
///   - textArr: 需要显示的文字数组,如果有换行请在文字中添加 "\n"换行符
///   - fontArr: 字体数组, 如果fontArr与textArr个数不相同则获取字体数组中最后一个字体
///   - colorArr: 颜色数组, 如果colorArr与textArr个数不相同则获取字体数组中最后一个颜色
///   - spacing: 换行的行间距
///   - alignment: 换行的文字对齐方式
/// - Returns: 属性文字
func createAttributedStr(textArr: [Any?],
                         fontArr: [UIFont],
                         colorArr: [UIColor],
                         spacing: CGFloat,
                         imgOffset: CGFloat = 12,
                         alignment: NSTextAlignment) -> NSMutableAttributedString? {
    
    guard textArr.count > 0, fontArr.count > 0, colorArr.count > 0 else {
        return nil
    }
    let allString: NSMutableString = ""
    for tempText in textArr {
        if let addText = tempText as? String {
            allString.append(addText)
        }
    }
    var lastTextRange = NSRange(location: 0, length: 0)
    var rangeArr: [String] = []
    
    for tempText in textArr {
        if let addText = tempText as? String {
            var range = allString.range(of: addText)
            
            //如果存在相同字符,则换一种查找的方法
            if allString.components(separatedBy: addText).count > 2 {
                range = NSRange(location: lastTextRange.location+lastTextRange.length, length: addText.count)
            }
            rangeArr.append(NSStringFromRange(range))
            lastTextRange = range
            
        } else if tempText is UIImage {
            let imgRange = NSRangeFromString(rangeArr.last!)
            if imgRange.location != NSNotFound {
                let addLocation = imgRange.location + imgRange.length
                rangeArr.append(NSStringFromRange(NSRange(location: addLocation, length: 1)))
            }
        }
    }
    var index = -1
    var imgTuples: [(NSInteger, NSAttributedString)] = []
    let textAttr = NSMutableAttributedString(string: allString as String)
    
    for tempText in textArr {
        index += 1
        let range = NSRangeFromString(rangeArr[index])
        
        if tempText is String {
            //设置字体
            let font = index > (fontArr.count-1) ? fontArr.last : fontArr[index]
            if let tFont = font {
                textAttr.addAttribute(NSAttributedString.Key.font, value: tFont, range: range)
            }
            //设置颜色
            let color = index > (colorArr.count-1) ? colorArr.last : colorArr[index]
            if let tColor = color {
                textAttr.addAttribute(NSAttributedString.Key.foregroundColor, value: tColor, range: range)
            }
        } else if let image = tempText as? UIImage {
            //设置图片
            let attachment = NSTextAttachment()
            attachment.image = image
            attachment.bounds = CGRect(x: 0, y: -imgOffset, width: image.size.width, height: image.size.height)
            let imageAttr = NSAttributedString(attachment: attachment)
            
            //保存图片位置信息
            imgTuples += [(range.location, imageAttr)]
        }
    }
    //插入图片
    for (location, imageAttr) in imgTuples {
        textAttr.insert(imageAttr, at: location)
    }
    //段落 <如果有换行>
    if allString.range(of: "\n").location != NSNotFound && spacing > 0 {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = spacing
        paragraph.alignment = alignment
        textAttr.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraph, range: NSRange(location: 0, length: allString.length))
    }
    return textAttr
}

///因为首次安装进来加载缓存时,没有缓存,因此有缓存的页面需要先加一个loadingView
func activityLoading(style: UIActivityIndicatorView.Style? = .gray, color: UIColor? = .gray) -> UIActivityIndicatorView {
    let loadingView = UIActivityIndicatorView(style: style ?? .gray)
    loadingView.hidesWhenStopped = true
    loadingView.color = color ?? .gray
    loadingView.startAnimating()
    return loadingView
}

/// 获取Loading弹框
/// - Parameter parmater: (可传字段包装含有kLoadingViewKey的键值对)
/// - Returns: Loading弹框父视图
fileprivate func fetchHUDSuperView(parmater: AnyObject?) -> UIView {
    if let loadingView =  parmater as? UIView {
        return loadingView
        
    } else if let dict = parmater as? Dictionary<String, Any> {
        if let view = dict[kLoadingViewKey], let loadingView =  view as? UIView {
            return loadingView
        }
    }
    var window: UIWindow
    let delegate = UIApplication.shared.delegate
    if let delegate = delegate, delegate.responds(to: #selector(getter: UIApplicationDelegate.window)) {
        window = delegate.window!!
    } else {
        window = UIWindow(frame: UIScreen.main.bounds)
        window.makeKeyAndVisible()
    }
    return window
}

/// 隐藏指定视图上的loading框
/// - Parameter view: 指定视图参数 (可传字段包装含有kLoadingViewKey的键值对)
func hideLoading(from view: AnyObject?, animation: Bool = true) {
    let loadingSuperView = fetchHUDSuperView(parmater: view)
    for tmpView in loadingSuperView.subviews where tmpView.tag == kLoadingHUDTag {
        if animation {
            UIView.animate(withDuration: 0.1) {
                tmpView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                tmpView.alpha = 0.0
            } completion: { _ in
                tmpView.removeFromSuperview()
            }
        } else {
            tmpView.removeFromSuperview()
        }
    }
}

/// 指定视图上显示loading框 (可传字段包装含有kLoadingViewKey的键值对)
/// - Parameter paramater: loading框的父视图, 如果传nil,则会在Window上显示
func showLoading(to paramater: AnyObject?, animation: Bool = false) {
    ///在主线程中显示UI
    DispatchQueue.main.async {
        
        let loadingSuperView = fetchHUDSuperView(parmater: paramater)
        hideLoading(from: paramater, animation: false)
        
        let oldToastView = loadingSuperView.viewWithTag(kLoadingHUDTag)
        oldToastView?.removeFromSuperview()
        
        let maskBgView = UIView(frame: loadingSuperView.bounds)
        maskBgView.backgroundColor = .clear
        maskBgView.tag = kLoadingHUDTag
        loadingSuperView.addSubview(maskBgView)
        
        let HUDSize: CGFloat = 72.0
        let x = (maskBgView.bounds.size.width - HUDSize) / 2.0
        let y = (maskBgView.bounds.size.height - HUDSize) / 2.0
        
        let indicatorBg = UIView(frame: CGRect(x: x, y: y, width: HUDSize, height: HUDSize))
        indicatorBg.backgroundColor = .init(white: 0, alpha: 0.7)
        indicatorBg.layer.masksToBounds = true
        indicatorBg.layer.cornerRadius = 12
        maskBgView.addSubview(indicatorBg)
        
        let loadingView = activityLoading(style: .whiteLarge, color: .white)
        loadingView.center = CGPoint(x: HUDSize/2, y: HUDSize/2)
        indicatorBg.addSubview(loadingView)
        
        if animation {
            maskBgView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            maskBgView.alpha = 0.0
            UIView.animate(withDuration: 0.1) {
                maskBgView.transform = CGAffineTransform(scaleX: 1, y: 1)
                maskBgView.alpha = 1.0
            }
        }
    }
}

/// 在指定视图上展示纯文本Toast
/// - Parameters:
///   - with: 纯文本Toast
///   - parmaters: (可传字段包装含有kLoadingViewKey的键值对)
func showToastText(_ message: String,
                   toView parmaters: AnyObject,
                   animation: Bool = true) {
    ///在主线程中显示UI
    DispatchQueue.main.async {
        
        let loadingSuperView = fetchHUDSuperView(parmater: parmaters)
        hideLoading(from: parmaters, animation: false)
        
        let oldToastView = loadingSuperView.viewWithTag(kLoadingHUDTag)
        oldToastView?.removeFromSuperview()
        
        //黑色半透明View
        let blackView = UIView(frame: .zero)
        blackView.tag = kLoadingHUDTag
        blackView.backgroundColor = UIColor(r: 51, g: 51, b: 51, a: 0.9)
        blackView.layer.cornerRadius = 4
        blackView.layer.masksToBounds = true
        loadingSuperView.addSubview(blackView)
        
        let horizontalMargin: CGFloat = 12.0 //水平方向间距
        let verticalMargin: CGFloat = 15.0 //垂直方向间距
        let maxTextWidth = kScreenWidth - horizontalMargin*4
        
        //提示文案
        let messageLabel = UILabel(frame: .zero)
        messageLabel.frame = CGRect(x: 0, y: 0, width: maxTextWidth, height: 0)
        messageLabel.textColor = .white
        messageLabel.font = .systemFont(ofSize: 14)
        messageLabel.textAlignment = .center
        messageLabel.preferredMaxLayoutWidth = maxTextWidth
        messageLabel.numberOfLines = 0
        messageLabel.text = message
        messageLabel.sizeToFit()
        let msgWidth = messageLabel.bounds.size.width
        let msgHeight = messageLabel.bounds.size.height
        messageLabel.frame = CGRect(x: 0, y: 0, width: min(msgWidth, maxTextWidth), height: msgHeight)
        blackView.addSubview(messageLabel)
        
        let blackViewWidth = min(msgWidth + horizontalMargin*2, kScreenWidth - horizontalMargin*2)
        let blackViewHeight = msgHeight + verticalMargin*2
        blackView.frame = CGRect(x: 0, y: 0, width: blackViewWidth, height: blackViewHeight)
        blackView.center = CGPoint(x: loadingSuperView.bounds.size.width/2, y: loadingSuperView.bounds.size.height / 2)
        messageLabel.center = CGPoint(x: blackView.bounds.size.width/2, y: blackView.bounds.size.height/2)
        
        var time: Double = Double(message.count) / 6.0
        time = max(kToastShowTime, time)
        time = min(5, time)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            if animation {
                UIView.animate(withDuration: 0.1) {
                    blackView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                    blackView.alpha = 0.0
                } completion: { _ in
                    blackView.removeFromSuperview()
                }
            } else {
                blackView.removeFromSuperview()
            }
        }
    }
}
