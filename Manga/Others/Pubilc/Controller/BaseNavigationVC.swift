//
//  BaseNavigationVC.swift
//  WXSwiftDemo
//
//  Created by Luke on 2021/8/3.
//

import UIKit
import JKSwiftExtension

enum UNavgationBarStyle {
    case theme
    case clear
    case white
}

class BaseNavigationVC: UINavigationController {
    
    // 设置NavigationBar背景颜色, 字体颜色, 字体大小
    func initialize()  {
        let navBar = UINavigationBar.appearance()
        navBar.barTintColor =  .white
        navBar.tintColor = .white
        navBar.titleTextAttributes = [
            .font : UIFont.boldSystemFont(ofSize: 18),
            //.foregroundColor : UIColor.white
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationStyle = .fullScreen
        navigationBar.isTranslucent = false
        initialize()
    }
    
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

		if #available(iOS 13.0, *) {
			let barApp = UINavigationBarAppearance()
			barApp.backgroundColor = .white
			barApp.titleTextAttributes = [
				.font : UIFont.boldSystemFont(ofSize: 18),
				.foregroundColor : UIColor.white
			]
			barApp.backgroundImage = navigationBar.backgroundImage(for: .default)
			navigationBar.standardAppearance = barApp
			navigationBar.scrollEdgeAppearance = barApp;
		}
    }
    
    // MARK: - 全局拦截Push事件
    var prohibitPush = false
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if prohibitPush {
            prohibitPush = false
            return
        }
        prohibitPush = animated
        
        if viewControllers.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
        
        if animated {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.prohibitPush = false
            }
        }
        
        ///添加返回按钮
        guard viewControllers.count > 1 else { return }
        viewController.navigationItem.hidesBackButton = true
        var target: UIViewController = self
        if viewController is BaseVC {
            target = viewController
        }
        let image = UIImage(named: "nav_back_black")?.colorImage(color: .black)
        let leftItem = UIBarButtonItem(image: image,
                                       style: .plain,
                                       target: target,
                                       action: #selector(goBackAction))
        leftItem.imageInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        viewController.navigationItem.leftBarButtonItem = leftItem
    }
    
    @objc func goBackAction() {
        if let vcArray = navigationController?.viewControllers, let lastVC = vcArray.last?.presentingViewController  {
            lastVC.dismiss(animated: true, completion: nil)
        } else {
            popViewController(animated: true)
        }
    }
    
    //MARK: - 拦截所有的pop事件
    var prohibitPop = false
    @discardableResult
    override func popViewController(animated: Bool) -> UIViewController? {
        if prohibitPop {
            prohibitPop = false
            return nil
        }
        if animated {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.prohibitPop = false
            }
        }
        let popVC = super.popViewController(animated: animated)
        if let popVC = popVC {
            NotificationCenter.default.removeObserver(popVC)
        }
        return popVC
    }

    //MARK: - 导航器销毁事件
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
