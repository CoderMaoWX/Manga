//
//  BaseVC.swift
//  WXSwiftDemo
//
//  Created by Luke on 2021/8/3.
//

import UIKit
import WXNetworkingSwift

class BaseVC: UIViewController {
    
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
    
    /// 安装: InjectionIII.app, 实现此方法进入实时调试模式(方法名: injected是固定的)
    @objc func injected() {
#if DEBUG
        print("进入实时调试模式: \(self)")
        self.viewDidLoad()
#endif
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //公共配置
        publicConfig()
        
        //初始化布局UI
        initAddSubView()
        
        layoutSubView()
    }
    
    // MARK: - 初始化布局UI
    func initAddSubView() {
        //由子类重写覆盖
    }
    func layoutSubView()  {
        //由子类重写覆盖
    }
    
    ///公共配置
    private func publicConfig() {
        view.backgroundColor = .white
        edgesForExtendedLayout = .all
        extendedLayoutIncludesOpaqueBars = false

        if #available(iOS 11.0, *) {
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    //MARK: - 空白页提示视图
    
    ///需要显示的自定义提示view
    fileprivate lazy var emptyTipView: WXEmptyTipView = {
        let tipView = WXEmptyTipView(frame: .zero)
        tipView.backgroundColor = view.backgroundColor ?? .white
        tipView.iconImage = UIImage(named: "empty_data_tip");
        tipView.title = "暂无数据"
        tipView.subTitle = nil
        tipView.buttonTitle = nil
        tipView.actionBtnBlcok = nil
        tipView.tag = kEmptyTipViewTag
        view.addSubview(tipView)
        return tipView
    }()
    
    ///配置显示空白提示页
    func showEmptyTipView(config: ( (WXEmptyTipView) -> () )? ) {
        if let config = config {
            config(emptyTipView)
        }
        view.bringSubviewToFront(emptyTipView)
        emptyTipView.isHidden = false
        emptyTipView.snp.remakeConstraints {
            $0.edges.equalTo(UIEdgeInsets.zero)
        }
    }
    
    ///隐藏空白提示页
    func hidenEmptyTipView() {
        emptyTipView.isHidden = true
    }
    
    //MARK: - 全局导航返回按钮事件
    @objc func goBackAction() {
        if let _ = presentingViewController {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    ///父类释放时取消子类所有请求操作
    lazy var requestTaskArr: [WXDataRequest] = {
        return Array<WXDataRequest>()
    }()
    
    func cancelRequestSessionTask() {
        let _ = requestTaskArr.map { requestTask in
            requestTask.cancel()
        }
    }
    
    //MARK: - 导航器销毁事件
    deinit {
        NotificationCenter.default.removeObserver(self)
        cancelRequestSessionTask()
        debugLog("♻️♻️♻️ \(self.className) 已销毁 ♻️♻️♻️")
    }
    
}
