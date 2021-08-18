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
    
    lazy var testLabel: UILabel = {
        let label = UILabel()
        label.text = "UILabel"
        label.backgroundColor = .gray
        label.frame = CGRect(x: 100, y: 100, width: 70, height: 20)
        return label
    }()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        testLabel.dotValue = nil
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
        view.addSubview(testLabel)
        testLabel.dotValue = "58"
        
        setNavBarLeftItem(info: ["测试1"]) { _ in
            self.testLabel.dotValue = "139"
        }
        
        setNavBarRightItem(infoArr: ["测试2", UIImage(named: "search_history_delete")! ] ) { idx in
            debugLog("self.testLabel.dotValue \(idx)")
        }
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
        view.backgroundColor = .background
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
