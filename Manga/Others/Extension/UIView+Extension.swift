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
    case leading
    case bottom
    case trailing
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
        line.backgroundColor = .groupTableViewBackground
        addSubview(line)
        
        switch position {
        case .top:
            line.snp.makeConstraints { make in
                make.top.leading.width.equalTo(self)
                make.height.equalTo(thinSize)
            }
        case .leading:
            line.snp.makeConstraints { make in
                make.leading.top.bottom.equalTo(self)
                make.width.equalTo(thinSize)
            }
        case .bottom:
            line.snp.makeConstraints { make in
                make.leading.bottom.trailing.equalTo(self)
                make.height.equalTo(thinSize)
            }
        case .trailing:
            line.snp.makeConstraints { make in
                make.top.trailing.bottom.equalTo(self)
                make.width.equalTo(thinSize)
            }
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
    func scaleAnimationToScale(_ scale: CGFloat) -> CAKeyframeAnimation {
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
    
    /// 设置/获取: 红色小圆点提示
    var showRedDot: Bool {
        get {
            let label = viewWithTag(kDotLabelTag) as? UILabel
            return (label != nil)
        }
        set {
            if newValue == false {
                let dotLabel = viewWithTag(kDotLabelTag)
                dotLabel?.removeFromSuperview()
                return
            }
            let label = (viewWithTag(kDotLabelTag) as? UILabel) ?? UILabel()
            label.tag = kDotLabelTag
            label.backgroundColor = .red
            let dotSize = 8.0
            label.layer.cornerRadius = dotSize / 2.0
            label.layer.masksToBounds = true
            label.clipsToBounds = true
            layer.masksToBounds = false
            clipsToBounds = false
            addSubview(label)
            label.snp.remakeConstraints {
                $0.leading.equalTo(self.snp.trailing).offset(-dotSize/2.0)
                $0.top.equalTo(self.snp.top).offset(-dotSize/2.0)
                $0.size.equalTo(CGSize(width: dotSize, height: dotSize))
            }
        }
    }
    
    /// 设置: 红色小圆点提示 (控制偏移位置)
    /// - Parameters:
    ///   - show: 是都显示红色小圆点
    ///   - offset: 在控件右上角中心位置的基础上进行 偏移控制
    func showRedDot(_ show: Bool, offset: CGPoint) {
        showRedDot = show
        if show == true, let dotLabel = viewWithTag(kDotLabelTag), dotLabel.superview != nil  {
            let dotSize = 8.0
            dotLabel.snp.remakeConstraints {
                $0.leading.equalTo(self.snp.trailing).offset(-dotSize/2 + offset.x)
                $0.top.equalTo(self.snp.top).offset(-dotSize/2 + offset.y)
                $0.size.equalTo(CGSize(width: dotSize, height: dotSize))
            }
        }
    }
    
    ///设置/获取: 数字提示 (红色背景,白色文字)
    var badgeValue: String? {
        get {
            let label = viewWithTag(kDotLabelTag) as? UILabel
            return label?.text
        }
        set {
            let badgeString = newValue?.replacingOccurrences(of: " ", with: "")
            if newValue == nil || badgeString!.count == 0 || Int(badgeString ?? "0") == 0 {
                let dotLabel = viewWithTag(kDotLabelTag)
                dotLabel?.removeFromSuperview()
                return
            }
            let badgeText = badgeString!
            let label = (viewWithTag(kDotLabelTag) as? UILabel) ?? UILabel()
            label.tag = kDotLabelTag
            label.text = badgeText
            label.backgroundColor = .red
            label.font = .boldSystemFont(ofSize: 12)
            label.textAlignment = .center
            label.textColor = .white
            if let number = Int(badgeText) {//数字类型: "100"
                label.text = ("\(number)".count > 2) ? "99+" : "\(number)"
            } else {//文字类型: "new"
                label.text = badgeText
            }
            label.sizeToFit()
            let dotH = label.bounds.size.height
            var dotW = label.bounds.size.width + (badgeText.count > 1 ? 5 : 0)
            if dotW < dotH { dotW = dotH }
            label.layer.cornerRadius = dotH / 2.0
            label.layer.masksToBounds = true
            label.clipsToBounds = true
            layer.masksToBounds = false
            clipsToBounds = false
            addSubview(label)
            label.snp.remakeConstraints {
                $0.leading.equalTo(self.snp.trailing).offset(-dotW/2.0)
                $0.top.equalTo(self.snp.top).offset(-dotH/2.0)
                $0.size.equalTo(CGSize(width: dotW, height: dotH))
            }
        }
    }
    
    /// 设置: 红点数字提示 (控制偏移位置)
    /// - Parameters:
    ///   - number: 提示的数字
    ///   - offset: 在控件右上角中心位置的基础上进行 偏移控制
    func badgeValue(_ number: String?, offset: CGPoint) {
        badgeValue = number
        if let numberString = number, let dotLabel = viewWithTag(kDotLabelTag), dotLabel.superview != nil  {
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




