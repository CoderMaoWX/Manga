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
    ///   - start headerRefreshing: 是否立即头部刷新
    func addRefreshKit(startHeader refreshing: Bool = false,
                       headerClosure: WXRefreshingBlock? = nil,
                       footerClosure: WXRefreshingBlock?  = nil) {
        //头部下拉
        if let headerClosure = headerClosure {
            mj_header = MJRefreshNormalHeader {  [weak self] in
                //1.先移除页面上已有的提示视图
                self?.removeBlankView()
                
                //2.每次下拉刷新时先结束上啦
                self?.mj_footer?.endRefreshing()
                
                headerClosure()
            }
            if refreshing {
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
//        let requestSuccess = pageInfo is Dictionary<String, Any>
        
    }
    
    /// 判断ScrollView页面上是否有数据
    /// - Returns: 是否有数据
    func isEmptyDataContentView() -> Bool {
        var isEmptyCell = true
        var sections = 1 //默认系统都只有1个sections
        
        if let tableView = self as? UITableView { ///当前页面是 UITableView子视图
            
            if tableView.tableHeaderView?.bounds.size.height ?? 0 > 10 ||
               tableView.tableFooterView?.bounds.size.height ?? 0 > 10 {
                return false
            }
            //计算有多少个Sections
            if let dataSource = tableView.dataSource {
                if dataSource.responds(to: #selector( dataSource.numberOfSections(in:))) {
                    sections = dataSource.numberOfSections?(in: tableView) ?? 1
                }
                for idx in 0..<sections {
                    let rows = dataSource.tableView(tableView, numberOfRowsInSection: idx)
                    if rows > 0 {
                        isEmptyCell = false
                        break
                    }
                }
            }
            // 如果每个Cell没有数据源, 则还需要判断Header和Footer高度是否为0
            if isEmptyCell, let delegate = tableView.delegate {
                var isEmptyHeader = true
                
                //检查是否有自定义HeaderView
                if delegate.responds(to: #selector(delegate.tableView(_:heightForHeaderInSection:))) {
                    for idx in 0..<sections {
                        let headerHeight = delegate.tableView?(tableView, heightForHeaderInSection: idx) ?? 0
                        if headerHeight > 1.0 {
                            isEmptyHeader = false
                            isEmptyCell = false
                            break
                        }
                    }
                } else if tableView.sectionHeaderHeight > 0 || tableView.estimatedSectionHeaderHeight > 0 {
                    isEmptyHeader = false
                    isEmptyCell = false
                }
                
                // 如果Header没有高度还要判断Footer是否有高度
                if isEmptyHeader, delegate.responds(to: #selector(delegate.tableView(_:heightForFooterInSection:))) {
                    for idx in 0..<sections {
                        let footerHeight = delegate.tableView?(tableView, heightForFooterInSection: idx) ?? 0
                        if footerHeight > 1.0 {
                            isEmptyCell = false
                            break
                        }
                    }
                } else if tableView.sectionFooterHeight > 0 || tableView.estimatedSectionFooterHeight > 0 {
                    isEmptyCell = false
                }
            }
            
        } else if let collectionView = self as? UICollectionView { ///当前页面是 UICollectionView子视图
            
            if let dataSource = collectionView.dataSource {
                
                if dataSource.responds(to: #selector(dataSource.collectionView(_:numberOfItemsInSection:))) {
                    sections = dataSource.numberOfSections?(in: collectionView) ?? 1
                }
                for idx in 0..<sections {
                    let items = dataSource.collectionView(collectionView, numberOfItemsInSection: idx)
                    if items > 0 {
                        isEmptyCell = false
                        break
                    }
                }
            }
            // 如果每个ItemCell没有数据源, 则还需要判断Header和Footer高度是否为0
            if isEmptyCell, let delegate = collectionView.delegate {
                
                ///<UICollectionViewDelegateFlowLayout>
                if let delegateFlowLayout = delegate as? UICollectionViewDelegateFlowLayout {
                    var isEmptyHeader = true
                    
                    //检查是否有自定义HeaderView
                    if delegateFlowLayout.responds(to: #selector(delegateFlowLayout.collectionView(_:layout:referenceSizeForHeaderInSection:))) {
                        
                        for idx in 0..<sections {
                            let headerSize = delegateFlowLayout.collectionView?(collectionView, layout: collectionView.collectionViewLayout, referenceSizeForHeaderInSection: idx) ?? .zero
                            
                            if headerSize.width > 1.0 || headerSize.height > 1.0 {
                                isEmptyHeader = false
                                isEmptyCell = false
                                break
                            }
                        }
                    } else if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                        if flowLayout.headerReferenceSize.width > 1.0 {
                            isEmptyHeader = false
                            isEmptyCell = false
                        }
                    }
                    
                    // 如果Header没有高度还要判断Footer是否有高度
                    if isEmptyHeader, delegateFlowLayout.responds(to: #selector(delegateFlowLayout.collectionView(_:layout:referenceSizeForFooterInSection:))) {
                        
                        for idx in 0..<sections {
                            let footerSize = delegateFlowLayout.collectionView?(collectionView, layout: collectionView.collectionViewLayout, referenceSizeForFooterInSection: idx) ?? .zero
                            
                            if footerSize.width > 1.0 || footerSize.height > 1.0 {
                                isEmptyCell = false
                                break
                            }
                        }
                    }  else if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                        if flowLayout.footerReferenceSize.width > 1.0 {
                            isEmptyCell = false
                        }
                    }
                }
                
                if !collectionView.collectionViewLayout.collectionViewContentSize.equalTo(.zero) {
                    isEmptyCell = false
                }
            }
            
        } else { ///当前页面是 UIScrollView 子视图
            if subviews.count > 0 {
                isEmptyCell = false
            }
        }
        return isEmptyCell
    }
}
