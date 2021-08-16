//
//  UtilsMethod.swift
//  Manga
//
//  Created by 610582 on 2021/8/13.
//

import Foundation
import UIKit


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
            controller = controller?.presentedViewController;
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

///因为首次安装进来加载缓存时,没有缓存,因此有缓存的页面需要先加一个loadingView
func activityLoading() -> UIActivityIndicatorView {
    let loadingView = UIActivityIndicatorView()
    loadingView.hidesWhenStopped = true
    loadingView.color = .gray
    loadingView.startAnimating()
    return loadingView
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
    gradient.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height);
    
    var startPoint = CGPoint.zero
    if direction == .DownDiagonalLine {
        startPoint = CGPoint(x: 0.0, y: 1.0)
    }
    gradient.startPoint = startPoint;
    
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
                         alignment: NSTextAlignment) -> NSAttributedString? {
    
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
            lastTextRange = range;
            
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
