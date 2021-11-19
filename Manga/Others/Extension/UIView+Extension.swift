//
//  UIViewExtension.swift
//  WXSwiftDemo
//
//  Created by 610582 on 2021/8/2.
//

import Foundation
import UIKit
import CoreGraphics
import SnapKit

///红点提示子视图
let kDotLabelTag = 1949


enum WXDrawLinePosition: Int {
    case top
    case left
    case bottom
    case right
}

extension UIView {
    
    fileprivate struct AssociatedKeys {
        static var tapGestureKey = "tapGestureKey"
    }
    
    ///获取视图所在的控制器
    func currentViewController() -> UIViewController? {
        for view in sequence(first: self.superview, next: {$0?.superview}){
            if let responder = view?.next{
                if responder.isKind(of: UIViewController.self){
                    return responder as? UIViewController
                }
            }
        }
        return nil
    }
    
    ///绘制圆角 要设置的圆角 使用“|”来组合
    func addCorners(corners: UIRectCorner, cornerRadii: CGSize) {
        let maskPath = UIBezierPath.init(roundedRect: bounds,
                                         byRoundingCorners: corners,
                                         cornerRadii: cornerRadii)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer
    }
    
    ///寻找子视图Tag
    func subViewWithTag(tag: Int) -> UIView? {
        for tmpView in subviews {
            if tmpView.tag == tag {
                return tmpView
            }
        }
        return nil
    }
    
    ///移除Window的Tag子视图
    func removeTagViewFromWindow(tag: Int) {
        let tagView = UIApplication.shared.delegate?.window
        tagView??.viewWithTag(tag)
    }
    
    /// 给当前视图添加线条
    /// - Parameters:
    ///   - position: 添加的位置
    ///   - thinSize: 天条宽度或高度
    /// - Returns: 添加的线条
    @discardableResult
    func addLineTo(position: WXDrawLinePosition, thinSize: CGFloat) -> UIView {
        let line = UIView()
        switch position {
        case .top:
            line.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: thinSize)
        
        case .left:
            line.frame = CGRect(x: 0, y: 0, width: thinSize, height: frame.size.height)
            
        case .bottom:
            line.frame = CGRect(x: 0, y: frame.size.height-thinSize, width: frame.size.width, height: thinSize)
            
        case .right:
            line.frame = CGRect(x: frame.size.width-thinSize, y: 0, width: thinSize, height: frame.size.height)
        }
        return line
    }
    
    ///给指定view顶部添加投影阴影
    func addDropShadow(with offset: CGSize, radius: CGFloat, color: UIColor, opacity: Float) {
        let path = CGMutablePath()
        path.addRect(bounds)
        layer.shadowPath = path
        path.closeSubpath()
        
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowRadius = radius;
        layer.shadowOpacity = opacity
        clipsToBounds = false;
    }
    
    ///左右摇摆抖动动画
    func shakeAnimation(times: Float) -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        //让动画先左旋转-M_PI_4 / 5，再右旋转同样的度数，再左旋转
        let MPI4 = Double.pi / 4
        animation.values = [(-MPI4 / 5), (MPI4 / 5), (-MPI4 / 5)];
        animation.duration = 0.25;
        //设置动画重复次数
        animation.repeatCount = times
        return animation
    }
    
    ///缩放动画 max：结束最大值
    func scaleToVlaueAnimation(scale: CGFloat) -> CAKeyframeAnimation {
        //FIXME: occ Bug 1101
        let a = transform.a;
        let b = transform.b;
        let c = transform.c;
        let d = transform.d;

        var resultAD: CGFloat = 1.0;
        if (a > 0 || a < 0) {
            resultAD *= a;
        }
        if (b > 0 || b < 0) {
            resultAD *= b;
        }
        if (c > 0 || c < 0) {
            resultAD *= c;
        }
        if (d > 0 || d < 0) {
            resultAD *= d;
        }
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.values = [resultAD * 0.1, resultAD * 1.0, resultAD * scale];
        animation.keyTimes = [(0.0), (0.5), (0.8), (1.0)]
        animation.calculationMode = .linear
        return animation;
    }
    
    ///设置/获取: 红点数字提示
    var redDotValue: String? {
        get {
            let dotLabel = viewWithTag(kDotLabelTag) as? UILabel
            return dotLabel?.text
        }
        set {
            if let number = Int(newValue ?? "0"), number == 0 {
                let dotLabel = viewWithTag(kDotLabelTag)
                dotLabel?.removeFromSuperview()
                return
            }
            if let text = newValue {
                let dotLabel = (viewWithTag(kDotLabelTag) as? UILabel) ?? UILabel()
                dotLabel.tag = kDotLabelTag
                dotLabel.text = text
                dotLabel.backgroundColor = .red
                dotLabel.font = .boldSystemFont(ofSize: 12)
                dotLabel.textAlignment = .center
                dotLabel.textColor = .white
                dotLabel.text = (text.count > 2) ? "99+" : text
                dotLabel.sizeToFit()
                let dotH = dotLabel.bounds.size.height
                var dotW = dotLabel.bounds.size.width + (text.count > 1 ? 5 : 0)
                if dotW < dotH { dotW = dotH }
                dotLabel.layer.cornerRadius = dotH / 2
                dotLabel.layer.masksToBounds = true
                dotLabel.clipsToBounds = true
                layer.masksToBounds = false
                clipsToBounds = false
                addSubview(dotLabel)
                dotLabel.snp.remakeConstraints {
                    $0.leading.equalTo(self.snp.trailing).offset(-dotW/2)
                    $0.top.equalTo(self.snp.top).offset(-dotH/2)
                    $0.size.equalTo(CGSize(width: dotW, height: dotH))
                }
            }
        }
    }
    
    /// 设置: 红点数字提示 (控制偏移位置)
    /// - Parameters:
    ///   - number: 提示的数字
    ///   - offset: 在控件右上角中心位置的基础上进行 偏移控制
    func redDotValue(_ number: String?, offset: CGPoint) {
        redDotValue = number
        let dotLabel = viewWithTag(kDotLabelTag)
        if let numberString = number, let dotLabel = dotLabel, dotLabel.superview != nil  {
            dotLabel.sizeToFit()
            let dotH = dotLabel.bounds.size.height
            var dotW = dotLabel.bounds.size.width + (numberString.count > 1 ? 5 : 0)
            if dotW < dotH {  dotW = dotH }
            dotLabel.snp.remakeConstraints {
                $0.leading.equalTo(self.snp.trailing).offset(-dotW/2 + offset.x)
                $0.top.equalTo(self.snp.top).offset(-dotH/2 + offset.y)
                $0.size.equalTo(CGSize(width: dotW, height: dotH))
            }
        }
    }
    
    public typealias TapGestureClosure = @convention(block) (_ view: UIView) -> Void
    var tapGestureHandler:TapGestureClosure? {
        get {
            let closureObject: AnyObject? = objc_getAssociatedObject(self, &AssociatedKeys.tapGestureKey) as AnyObject?
            guard closureObject != nil else {
                return nil
            }
            let closure = unsafeBitCast(closureObject, to: TapGestureClosure.self)
            return closure
        }
        set {
            guard let value = newValue else {  return }
            let dealObject: AnyObject = unsafeBitCast(value, to: AnyObject.self)
            objc_setAssociatedObject(self, &AssociatedKeys.tapGestureKey,dealObject,objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    ///给视图添加手势
    func addTapGesture(complete: @escaping TapGestureClosure) {
        self.tapGestureHandler = complete
        isUserInteractionEnabled = true
        isExclusiveTouch = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapViewGestureAction))
        addGestureRecognizer(tapGesture)
    }
    
    @objc func tapViewGestureAction() {
        guard let tapClosure = self.tapGestureHandler else {
            return
        }
        tapClosure(self)
    }
    
    ///DEBUG模式下 显示调试UI边框
    func showDebugBorder() {
        #if DEBUG
            layer.borderColor = UIColor.red.cgColor
            layer.borderWidth = 0.5
        #endif
    }
}




