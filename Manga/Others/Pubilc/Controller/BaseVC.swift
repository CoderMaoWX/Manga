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
        
        //测试代码
        testAlert()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        showLoading(toView: view)
    }
    
    // MARK: - 初始化布局UI
    func initSubView() {
        //由子类重写覆盖
    }
    func layoutSubView()  {
        //由子类重写覆盖
    }
    
    //MARK: ----- 测试代码 -----
    func testAlert() {
        setNavBarLeftItem(info: ["测试3"]) { _ in
            hideLoading(from: self.view)
        }
        let img1 = UIImage(named: "search_history_delete")!
        let img2 = UIImage(named: "search_keyword_refresh")!

        let btnArr = setNavBarRightItem(infoArr: [img1, img2] ) { idx in
            debugLog("self.testLabel.dotValue", idx, "后缀")
            showToastText("测试一下Toast", toView: self.view)
        }
        btnArr.first!.redDotValue = "18"
    }
        
//        setNavBarRightItem(infoArr: ["谈事"]) { _ in
//            showAlertMultiple(title: "请闭上眼睛", message: "休息一下,马上回来...", otherBtnTitles: ["我要工作", "努力赚钱"], otherBtnClosure: { idx, title in
//                debugLog("== 好好工作 ==idx=\(idx), title=\(title)");
//
//            }, cancelTitle: "好的") {
//                debugLog("== 好的 ==");
//            }
//        }
//    }
    
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
        
        if let nav = navigationController as? BaseNavigationVC {
            nav.barStyle(.theme)
        }
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
    }
    
}
