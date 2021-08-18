//
//  UIViewControllerExtension.swift
//  WXSwiftDemo
//
//  Created by 610582 on 2021/8/2.
//

import Foundation
import UIKit

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
        static var navBarItemTypeKey = "navBarItemTypeKey"
        static var navBarLeftItemKey = "navBarLeftItemKey"
        static var navBarRightItemKey = "navBarRightItemKey"
    }
    
    ///避免KVC设值异常
    open override class func setValue(_ value: Any?, forUndefinedKey key: String) {
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
    
    typealias NavBarItemActionClosure = @convention(block) (_ index: Int) -> ()
    ///添加左侧导航按钮
    func setNavBarLeftItem(info: [Any], actionClosure: @escaping NavBarItemActionClosure ) {
        let itemArr = createNavBarItems(object: info, itemType:1, actionClosure: actionClosure)
        navigationItem.leftBarButtonItems = itemArr
    }
    
    ///添加右侧导航按钮
    func setNavBarRightItem(infoArr: [Any], actionClosure: @escaping NavBarItemActionClosure ) {
        let itemArr = createNavBarItems(object: infoArr, itemType:2, actionClosure: actionClosure)
        navigationItem.rightBarButtonItems = itemArr
    }

    ///添加导航按钮
    func createNavBarItems(object: [Any],
                           itemType: Int,
                           actionClosure: @escaping NavBarItemActionClosure ) -> [UIBarButtonItem] {
        var barItemArr: [UIBarButtonItem] = []
        var index = -1
        
        for info in object {
            let button = UIButton(type: .system)
            if info is UIImage {
                var image = info as! UIImage
                image = image.withRenderingMode(.alwaysOriginal)
                button.setImage(image, for: .normal)
                button.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
                
            } else if info is String {
                button.setTitle((info as! String), for: .normal)
                button.titleLabel?.font = .systemFont(ofSize: 14)
                button.sizeToFit()
                button.frame = CGRect(x: 0, y: 0, width: button.bounds.size.width, height: 30)
                button.setTitleColor(UIColor.black, for: .normal)
                
            }  else if info is NSAttributedString {
                button.titleLabel?.font = .systemFont(ofSize: 14)
                button.setAttributedTitle((info as! NSAttributedString), for: .normal)
                button.sizeToFit()
                button.frame = CGRect(x: 0, y: 0, width: button.bounds.size.width, height: 30)
                button.setTitleColor(UIColor.black, for: .normal)
            } else {
                continue
            }
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
            button.addTarget(self, action: #selector(navBarItemAction), for: .touchUpInside)
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
            barItemArr .insert(contentsOf: [barItem, spaceItem], at: 0)
        }
        return barItemArr
    }
    
    @objc func navBarItemAction(sender: UIButton) {
        let itemType: AnyObject? = objc_getAssociatedObject(self, &AssociatedKeys.navBarItemTypeKey) as AnyObject?
        guard let type = itemType as? Int else { return }
        
        var closureObject: AnyObject?
        if type == 1 {
            closureObject = objc_getAssociatedObject(self, &AssociatedKeys.navBarLeftItemKey) as AnyObject?
        } else {
            closureObject = objc_getAssociatedObject(self, &AssociatedKeys.navBarRightItemKey) as AnyObject?
        }
        guard closureObject != nil else { return }
        let closure = unsafeBitCast(closureObject, to: NavBarItemActionClosure.self)
        closure(sender.tag)
    }
    
}

