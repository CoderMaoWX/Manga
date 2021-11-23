//
//  UIViewControllerExtension.swift
//  WXSwiftDemo
//
//  Created by 610582 on 2021/8/2.
//

import Foundation
import UIKit

typealias NavBarItemActionClosure = @convention(block) (_ button: UIButton) -> ()

extension UIViewController {
    
    @objc class func swizzlingMethod() {
        let originalSelector = #selector(UIViewController.viewDidAppear(_:))
        let swizzledSelector = #selector(UIViewController.wx_viewDidAppear(animated:))

        let originalMethod = class_getInstanceMethod(self, originalSelector)
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)

        //在进行 Swizzling 的时候,需要用 class_addMethod 先进行判断一下原有类中是否有要替换方法的实现
        let didAddMethod: Bool = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
        //如果 class_addMethod 返回 yes,说明当前类中没有要替换方法的实现,所以需要在父类中查找,这时候就用到 method_getImplemetation 去获取 class_getInstanceMethod 里面的方法实现,然后再进行 class_replaceMethod 来实现 Swizzing
        if didAddMethod {
            class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
        } else {
            method_exchangeImplementations(originalMethod!, swizzledMethod!)
        }
    }
    
    @objc func wx_viewDidAppear(animated: Bool) {
        self.wx_viewDidAppear(animated: animated)
        debugLog("wx_viewDidAppear 替换了", self.className)
    }
    
    fileprivate struct AssociatedKeys {
        static var navBarItemTypeKey: Void?
        static var navBarLeftItemKey: Void?
        static var navBarRightItemKey: Void?
    }
    
    ///避免KVC设值异常
    open override func setValue(_ value: Any?, forUndefinedKey key: String) {
        debugLog("❌❌❌ 警告:", "\(self.self)", "类没有实现该属性: ", key)
    }
    
    ///模态一个半透明的视图。
    func presentTranslucentVC(tagrtVC: UIViewController, animated: Bool, completion: @escaping ()->()) {
        
        // 用于显示这个视图控制器的视图是否覆盖当视图控制器或其后代提供了一个视图控制器。默认为NO
        definesPresentationContext = true;
        // 设置页面切换效果
        modalTransitionStyle = .crossDissolve;
        // .currentContext能在当前VC上present一个新的VC同时不覆盖之前的内容
        tagrtVC.modalPresentationStyle = .currentContext //.fullScreen
        
        present(tagrtVC, animated: animated) {
            self.presentedViewController?.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
            completion()
        }
    }
    
    
    //MARK: ======== UIBarButtonItem ========
    
    /// 添加左侧导航按钮
    /// - Parameters:
    ///   - info: 数组装多个: String/UIImage
    ///   - actionClosure: 按钮的回调事件
    /// - Returns: 返回多个: UIButton
    @discardableResult
    func setNavBarLeftItem(info: [Any], actionClosure: @escaping NavBarItemActionClosure ) -> [UIButton] {
        let tuples = createNavBarItems(object: info, itemType:1, actionClosure: actionClosure)
        navigationItem.leftBarButtonItems = tuples.0
        return tuples.1
    }
    
    /// 添加右侧导航按钮
    /// - Parameters:
    ///   - infoArr: 数组装多个: String/UIImage
    ///   - actionClosure: 按钮的回调事件
    /// - Returns: 返回多个: UIButton
    @discardableResult
    func setNavBarRightItem(info: [Any], actionClosure: @escaping NavBarItemActionClosure ) -> [UIButton] {
        let tuples = createNavBarItems(object: info, itemType:2, actionClosure: actionClosure)
        navigationItem.rightBarButtonItems = tuples.0
        return tuples.1
    }

    ///添加导航按钮
    func createNavBarItems(object: [Any],
                           itemType: Int,
                           actionClosure: @escaping NavBarItemActionClosure ) -> ([UIBarButtonItem], [UIButton]) {
        var barItemArr: [UIBarButtonItem] = []
        var barButtonArr: [UIButton] = []
        var index = -1
        
        for info in object {
            let button = UIButton(type: .system)
            if info is UIImage {
                var image = info as! UIImage
                image = image.withRenderingMode(.alwaysOriginal)
                button.setImage(image, for: .normal)
                
            } else if info is String {
                button.setTitle((info as! String), for: .normal)
                button.titleLabel?.font = .systemFont(ofSize: 14)
                
            }  else if info is NSAttributedString {
                button.titleLabel?.font = .systemFont(ofSize: 14)
                button.setAttributedTitle((info as! NSAttributedString), for: .normal)            } else {
                continue
            }
            button.sizeToFit()
            button.setTitleColor(UIColor.black, for: .normal)
            let width = max(30, button.bounds.size.width)
            let height = max(30, button.bounds.size.height)
            button.frame = CGRect(x: 0, y: 0, width: width , height: height)
            button.snp.makeConstraints {
                $0.size.equalTo(CGSize(width: width, height: height))
            }
            //let leftSpace: CGFloat = (itemType == 1) ? -8 : 0 //设置偏移
            //let rightSpace: CGFloat = (itemType == 1) ? 0 : -15
            //button.contentEdgeInsets = UIEdgeInsets(top: 0, left: leftSpace, bottom: 0, right: rightSpace)
            button.addTarget(self, action: #selector(self.navBarItemAction), for: .touchUpInside)
            index += 1
            button.tag = index
            
            objc_setAssociatedObject(button, &AssociatedKeys.navBarItemTypeKey, itemType, .OBJC_ASSOCIATION_ASSIGN)
            
            let dealObject: AnyObject = unsafeBitCast(actionClosure, to: AnyObject.self)
            if itemType == 1 {
                objc_setAssociatedObject(self, &AssociatedKeys.navBarLeftItemKey, dealObject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            } else {
                objc_setAssociatedObject(self, &AssociatedKeys.navBarRightItemKey, dealObject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            let barItem = UIBarButtonItem(customView: button)
            let spaceItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            spaceItem.width = 15
            barButtonArr.append(button)
            if itemType == 1 {
                barItemArr.append(barItem)
            } else {
                barItemArr.insert(contentsOf: [barItem], at: 0)
            }
        }
        return (barItemArr, barButtonArr)
    }
    
    @objc func navBarItemAction(sender: UIButton) {
        let itemType = objc_getAssociatedObject(sender, &AssociatedKeys.navBarItemTypeKey)
        guard let type = itemType as? Int else { return }
        
        var closureObject: AnyObject?
        if type == 1 {
            closureObject = objc_getAssociatedObject(self, &AssociatedKeys.navBarLeftItemKey) as AnyObject?
        } else {
            closureObject = objc_getAssociatedObject(self, &AssociatedKeys.navBarRightItemKey) as AnyObject?
        }
        guard closureObject != nil else { return }
        let closure = unsafeBitCast(closureObject, to: NavBarItemActionClosure.self)
        closure(sender)
    }
    
}

