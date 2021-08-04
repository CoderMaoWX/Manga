//
//  UIbuttonExtension.swift
//  WXSwiftDemo
//
//  Created by Luke on 2021/8/2.
//

import Foundation
import UIKit

enum ButtonEdgeInsetsStyle {
    case ImgTop_LabelBottom  // image在上，label在下
    case ImgLeft_LabelRight  // image在左，label在右
    case ImgBottom_LabelTop  // image在下，label在上
    case ImgRight_LabeLeft   // image在右，label在左
}

extension UIButton {
    
    /// 设置button的titleLabel和imageView的布局样式，及间距
    /// - Parameters:
    ///   - style: titleLabel和imageView的布局样式
    ///   - space: titleLabel和imageView的间距
    func layoutImageTitle(style: ButtonEdgeInsetsStyle, space: CGFloat) {
        //强制更新布局，以获得最新的 imageView 和 titleLabel 的 frame
        layoutIfNeeded()
        
        // 1. 得到imageView和titleLabel的宽、高
        let imageWith = imageView?.intrinsicContentSize.width ?? 0.0
        let imageHeight = imageView?.intrinsicContentSize.height ?? 0.0
        
        let labelWidth = titleLabel?.intrinsicContentSize.width ?? 0.0
        let labelHeight = titleLabel?.intrinsicContentSize.height ?? 0.0

        // 2. 声明全局的imageEdgeInsets和labelEdgeInsets
        var imgEdgeInsets = UIEdgeInsets.zero
        var labelEdgeInsets = UIEdgeInsets.zero

        //是否为阿语,从右往左显示
        let leftToRight = UIView.appearance().semanticContentAttribute == .forceRightToLeft
        
        switch style {
        case .ImgTop_LabelBottom: //image在上，label在下
            if (leftToRight) {
                imgEdgeInsets = UIEdgeInsets(top: -labelHeight-space/2.0, left: -labelWidth, bottom: 0.0, right: 0.0)
                labelEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: -imageHeight-space/2.0, right: -imageWith)
            } else {
                imgEdgeInsets = UIEdgeInsets(top: -labelHeight-space/2.0, left: 0, bottom: 0, right: -labelWidth)
                labelEdgeInsets = UIEdgeInsets(top: 0, left: -imageWith, bottom: -imageHeight-space/2.0, right: 0);
            }
        case .ImgLeft_LabelRight: //image在左，label在右
            if (leftToRight) {
                imgEdgeInsets = UIEdgeInsets(top: 0, left: space/2.0, bottom: 0, right: -space/2.0)
                labelEdgeInsets = UIEdgeInsets(top: 0, left: -space/2.0, bottom: 0, right: space/2.0)
            } else {
                imgEdgeInsets = UIEdgeInsets(top: 0, left: -space/2.0, bottom: 0, right: space/2.0)
                labelEdgeInsets = UIEdgeInsets(top: 0, left: space/2.0, bottom: 0, right: -space/2.0);
            }
        case .ImgBottom_LabelTop: //image在下，label在上
            if (leftToRight) {
                imgEdgeInsets = UIEdgeInsets(top: 0, left: -labelWidth, bottom: -labelHeight-space/2.0, right: 0)
                labelEdgeInsets = UIEdgeInsets(top: -imageHeight-space/2.0, left: 0, bottom: 0, right: -imageWith)
            } else {
                imgEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: -labelHeight-space/2.0, right: -labelWidth)
                labelEdgeInsets = UIEdgeInsets(top: -imageHeight-space/2.0, left: -imageWith, bottom: 0, right: 0);
            }
        case .ImgRight_LabeLeft: // image在右，label在左
            if (leftToRight) {
                imgEdgeInsets = UIEdgeInsets(top: 0, left: -labelWidth-space/2.0, bottom: 0, right: labelWidth+space/2.0)
                labelEdgeInsets = UIEdgeInsets(top: 0, left: imageWith+space/2.0, bottom: 0, right: -imageWith-space/2.0)
            } else {
                imgEdgeInsets = UIEdgeInsets(top: 0, left: labelWidth+space/2.0, bottom: 0, right: -labelWidth-space/2.0)
                labelEdgeInsets = UIEdgeInsets(top: 0, left: -imageWith-space/2.0, bottom: 0, right: imageWith+space/2.0);
            }
        }
        titleEdgeInsets = labelEdgeInsets
        imageEdgeInsets = imgEdgeInsets
    }
    
    /// 设置按钮不同状态的背景颜色（代替图片）
    func setBackgroundColor(color: UIColor, for state: UIControl.State) {
        let size = CGSize(width: 20, height: 20)
        let img = UIImage.createImage(with: color, size: size)
        self.setBackgroundImage(img, for: state)
    }
    
    
}
