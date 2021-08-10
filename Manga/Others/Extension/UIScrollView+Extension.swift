//
//  UIScrollViewExtension.swift
//  WXSwiftDemo
//
//  Created by 610582 on 2021/8/2.
//

import Foundation
import UIKit
import MJRefresh

//当前提示view在父视图上的tag
let kBlankTipViewTag: Int = 1990

///空白提示页
class WXBlankTipView: UIView {
    
}

extension UIScrollView {
    
    enum WXBlankTipViewStatus {
        case WXBlankTipViewStatus_Normal        //0 正常状态
        case WXBlankTipViewStatus_EmptyData     //1 空数据状态
        case WXBlankTipViewStatus_Fail          //2 请求失败状态
        case WXBlankTipViewStatus_NoNetWork     //3 网络连接失败状态
    }
    
    fileprivate struct AssociatedKeys {
        static var emptyDataTitleKey: Void?
        static var emptyDataSubTitleKey: Void?
        static var emptyDataImageKey: Void?
        static var emptyDataBtnTitleKey: Void?
        static var requestFailTitleKey: Void?
        static var requestFailImageKey: Void?
        static var requestFailBtnTitleKey: Void?
        static var networkErrorTitleKey: Void?
        static var networkErrorImageKey: Void?
        static var networkErrorBtnTitleKey: Void?
        static var blankTipViewActionBlcokKey: Void?
    }
    
    ///空数据标题
    var emptyDataTitle: String? {
        get { (objc_getAssociatedObject(self, &AssociatedKeys.emptyDataTitleKey) as? String) }
        set { objc_setAssociatedObject(self, &AssociatedKeys.emptyDataTitleKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    ///空数据副标题
    var emptyDataSubTitle: String? {
        get { (objc_getAssociatedObject(self, &AssociatedKeys.emptyDataSubTitleKey) as? String) }
        set { objc_setAssociatedObject(self, &AssociatedKeys.emptyDataSubTitleKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    ///空数据图片
    var emptyDataImage: UIImage {
        get { (objc_getAssociatedObject(self, &AssociatedKeys.emptyDataImageKey) as? UIImage) ?? UIImage(named: "search_no_data")! }
        set { objc_setAssociatedObject(self, &AssociatedKeys.emptyDataImageKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    ///空数据按钮标题
    var emptyDataBtnTitle: String? {
        get { (objc_getAssociatedObject(self, &AssociatedKeys.emptyDataBtnTitleKey) as? String) }
        set { objc_setAssociatedObject(self, &AssociatedKeys.emptyDataBtnTitleKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    ///请求失败文字
    var requestFailTitle: String? {
        get { (objc_getAssociatedObject(self, &AssociatedKeys.requestFailTitleKey) as? String) }
        set { objc_setAssociatedObject(self, &AssociatedKeys.requestFailTitleKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    ///请求失败图片
    var requestFailImage: UIImage {
        get { (objc_getAssociatedObject(self, &AssociatedKeys.requestFailImageKey) as? UIImage) ?? UIImage(named: "blankPage_networkError")! }
        set { objc_setAssociatedObject(self, &AssociatedKeys.requestFailImageKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    ///请求失败按钮
    var requestFailBtnTitle: String? {
        get { (objc_getAssociatedObject(self, &AssociatedKeys.requestFailBtnTitleKey) as? String) }
        set { objc_setAssociatedObject(self, &AssociatedKeys.requestFailBtnTitleKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    ///网络连接失败文字
    var networkErrorTitle: String? {
        get { (objc_getAssociatedObject(self, &AssociatedKeys.networkErrorTitleKey) as? String) }
        set { objc_setAssociatedObject(self, &AssociatedKeys.networkErrorTitleKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    ///网络连接失败图片
    var networkErrorImage: UIImage {
        get { (objc_getAssociatedObject(self, &AssociatedKeys.networkErrorImageKey) as? UIImage) ?? UIImage(named: "blankPage_networkError")! }
        set { objc_setAssociatedObject(self, &AssociatedKeys.networkErrorImageKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    ///网络连接失败按钮
    var networkErrorBtnTitle: String? {
        get { (objc_getAssociatedObject(self, &AssociatedKeys.networkErrorBtnTitleKey) as? String) }
        set { objc_setAssociatedObject(self, &AssociatedKeys.networkErrorBtnTitleKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    
    typealias blankTipViewBlockType = (WXBlankTipViewStatus) -> ()
    
    ///按钮点击的事件
    var blankTipViewActionBlcok: blankTipViewBlockType? {
        get { objc_getAssociatedObject(self, &AssociatedKeys.blankTipViewActionBlcokKey) as? blankTipViewBlockType }
        set { objc_setAssociatedObject(self, &AssociatedKeys.blankTipViewActionBlcokKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    
    //MARK: - 表格的上下拉刷新控件
    
    typealias WXRefreshingBlock = () -> ()
    
    /// 初始化表格的上下拉刷新控件
    /// - Parameters:
    ///   - headerClosure: 下拉刷新需要调用的函数
    ///   - footerClosure: 上拉刷新需要调用的函数
    ///   - startHeaderRefreshing: 是否立即头部刷新
    func addRefreshKit(headerClosure: WXRefreshingBlock? = nil,
                       footerClosure: WXRefreshingBlock?  = nil,
                       startHeaderRefreshing: Bool = false) {
        //头部下拉
        if let headerClosure = headerClosure {
            mj_header = MJRefreshNormalHeader {  [weak self] in
                //1.先移除页面上已有的提示视图
                self?.removeBlankView()
                
                //2.每次下拉刷新时先结束上啦
                self?.mj_footer?.endRefreshing()
                
                headerClosure()
            }
            if startHeaderRefreshing {
                mj_header?.beginRefreshing()
            }
        }
        //尾部上拉
        if let footerClosure = footerClosure {
            let footer = MJRefreshAutoNormalFooter(refreshingBlock: {
                footerClosure()
            })
            footer.isAutomaticallyRefresh = true
            let height = UIScreen.main.bounds.size.height
            footer.triggerAutomaticallyRefreshPercent = -height / 50.0 //预加载下一页数据
            footer.isHidden = true // 这里需要先隐藏,否则已进入页面没有数据也会显示上拉View
            mj_footer = footer
        }
    }
    
    ///移除页面上已有的提示视图
    func removeBlankView() {
        for tmpView in subviews {
            if tmpView is WXBlankTipView, tmpView.tag == kBlankTipViewTag {
                tmpView.removeFromSuperview()
            }
        }
    }
    
    //MARK: - 添加空白页总方法入口
    func judgeBlankView(pageInfo: Dictionary<String, Any>?) {
        
        self.mj_header?.endRefreshing()
        self.mj_footer?.endRefreshing()
        
        //判断请求状态: totalCurrentPageInfo为字典就是请求成功, 否则为请求失败
        let requestSuccess = pageInfo is Dictionary<String, Any>
        
//        BOOL requestSuccess = [totalCurrentPageInfo isKindOfClass:[NSDictionary class]];
        
        
    }
}
