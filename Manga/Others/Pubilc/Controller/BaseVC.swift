//
//  BaseVC.swift
//  WXSwiftDemo
//
//  Created by Luke on 2021/8/3.
//

import UIKit

class BaseVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //公共配置
        publicConfig()
        
        //初始化布局UI
        initSubView()
        
        layoutSubView()
    }
    
    // MARK: - 初始化布局UI
    func initSubView() {
        //由子类重写覆盖
    }
    func layoutSubView()  {
        //由子类重写覆盖
    }
    
    ///公共配置
    func publicConfig() {
        view.backgroundColor = .white
        edgesForExtendedLayout = .all
        extendedLayoutIncludesOpaqueBars = false

        if #available(iOS 11.0, *) {
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.window?.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        if let nav = navigationController as? BaseNavigationVC {
//            nav.barStyle(.theme)
//        }
    }
    
    //MARK: - 全局导航返回按钮事件
    @objc func goBackAction() {
        let vcArray: [UIViewController]! = navigationController?.viewControllers
        if vcArray.count > 1, vcArray?.last == self {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: - 导航器销毁事件
    deinit {
        NotificationCenter.default.removeObserver(self)
        debugLog("♻️♻️♻️ \(self.className) 已销毁 ♻️♻️♻️")
    }
    
}
