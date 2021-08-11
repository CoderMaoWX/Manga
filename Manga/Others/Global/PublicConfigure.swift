//
//  PublicConfigure.swift
//  WXSwiftDemo
//
//  Created by Luke on 2021/8/3.
//

import UIKit

class PublicConfigure: NSObject {

    static func appearanceConfigure() {
        //ScrollView去除顶部多余空间
        if #available(iOS 11.0, *) {
            UIScrollView.appearance().contentInsetAdjustmentBehavior = .never
        }
        
        //配置全局输入框光标颜色
        let tinColor = UIColor.hex("0x000000")
        UITextField.appearance().tintColor(tinColor)
        UITextView.appearance().tintColor(tinColor)
        
        //全局表格分割线设置统一颜色值
        UITableView.appearance().tintColor(UIColor.hex("0xDDDDDD"))

        //全局禁止视图多指点击
        UIView.appearance().isExclusiveTouch = true
        
        //文本: 是否为阿语,从右往左显示
        let leftToRight = UIView.appearance().semanticContentAttribute == .forceRightToLeft
        UILabel.appearance().textAlignment = leftToRight ? .left : .right
    }
    
}
