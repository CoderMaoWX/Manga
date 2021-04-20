//
//  NavigationVC.swift
//  U17Demo
//
//  Created by 610582 on 2021/2/1.
//

import UIKit

enum UNavgationBarStyle {
    case theme
    case clear
    case white
}

class NavigationVC: UINavigationController {
    
    // 设置NavigationBar背景颜色, 字体颜色, 字体大小
    func initialize()  {
        let navBar = UINavigationBar.appearance()
        navBar.barTintColor =  UIColor.white
        navBar.tintColor =  UIColor.white
        navBar.titleTextAttributes = [
            .font : UIFont.systemFont(ofSize: 18),
            .foregroundColor : UIColor.white
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.isTranslucent = false
        initialize()
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if self.viewControllers.count >= 1 {
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension UINavigationController {
    
    func barStyle(_ style: UNavgationBarStyle) {
        switch style {
        case .theme:
            navigationBar.barStyle = .black
            navigationBar.setBackgroundImage(UIImage(named: "nav_bg"), for: .default)
            navigationBar.shadowImage = UIImage()
            
        case .clear:
            navigationBar.barStyle = .black
            navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationBar.shadowImage = UIImage()
            
        case .white:
            navigationBar.barStyle = .default
            navigationBar.setBackgroundImage(UIColor.white.image(), for: .default)
            navigationBar.shadowImage = nil
        }
    }
}
