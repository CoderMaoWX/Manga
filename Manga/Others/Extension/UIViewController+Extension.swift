//
//  UIViewControllerExtension.swift
//  WXSwiftDemo
//
//  Created by 610582 on 2021/8/2.
//

import Foundation
import UIKit

extension UIViewController {
    
    fileprivate struct AssociatedKeys {
        static var navBarButtonItemKey = "navBarButtonItemKey"
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
                    controller = tabBarController?.selectedViewController
                    
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
    
    
    ///避免KVC设值异常
    open override class func setValue(_ value: Any?, forUndefinedKey key: String) {
        print("❌❌❌ 警告:", "\(self.self)", "类没有实现该属性: ", key)
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
        let itemArr = createNavBarItems(object: info, actionClosure: actionClosure)
        navigationItem.leftBarButtonItems = itemArr
    }
    
    ///添加右侧导航按钮
    func setNavBarRightItem(infoArr: [Any], actionClosure: @escaping NavBarItemActionClosure ) {
        let itemArr = createNavBarItems(object: infoArr, actionClosure: actionClosure)
        navigationItem.rightBarButtonItems = itemArr
    }

    ///添加导航按钮
    func createNavBarItems(object: [Any], actionClosure: @escaping NavBarItemActionClosure ) -> [UIBarButtonItem] {
        var barItemArr: [UIBarButtonItem] = []
        var index = -1
        
        for info in object {
            let button = UIButton()
            if info is UIImage {
                let image = info as! UIImage
                button.setImage(image, for: .normal)
                button.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
                
            } else if info is String {
                button.setTitle((info as! String), for: .normal)
                button.sizeToFit()
                button.frame = CGRect(x: 0, y: 0, width: button.bounds.size.width, height: 30)
                button.setTitleColor(UIColor.black, for: .normal)
                
            }  else if info is NSAttributedString {
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
            
            let dealObject: AnyObject = unsafeBitCast(actionClosure, to: AnyObject.self)
            objc_setAssociatedObject(self, &AssociatedKeys.navBarButtonItemKey,dealObject,objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            let barItem = UIBarButtonItem(customView: button)
            let spaceItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            barItemArr += [spaceItem, barItem]
        }
        return barItemArr
    }
    
    @objc func navBarItemAction(sender: AnyObject) {
        let closureObject: AnyObject? = objc_getAssociatedObject(self, &AssociatedKeys.navBarButtonItemKey) as AnyObject?
        guard closureObject != nil else { return }
        let closure = unsafeBitCast(closureObject, to: NavBarItemActionClosure.self)
        closure(sender.tag)
    }
    
}

