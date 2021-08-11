//
//  UIScrollViewExtension.swift
//  WXSwiftDemo
//
//  Created by 610582 on 2021/8/2.
//

import Foundation
import UIKit
import MJRefresh
import SnapKit

//判断表格数据空白页和分页的字段key
let kBlankViewTotalPageKey    = "pageCount"
let kBlankViewCurrentPageKey  = "curPage"
let kBlankViewListKey         = "list"

//当前提示view在父视图上的tag
let kBlankTipViewTag: Int = 1990

///空白提示页
class WXBlankTipView: UIView {
    var iconImage: UIImage? = nil
    var title: String? = nil
    var subTitle: String? = nil
    var buttonTitle: String? = nil
    var actionBtnBlcok: (()->()?)? = nil
    
    var contenViewOffsetPoint: CGPoint? {
        didSet {
            guard let contenViewOffsetPoint = contenViewOffsetPoint else { return }
        }
    }
    
    
}

extension UIScrollView {
    
    enum WXBlankTipViewStatus {
        case Normal        //0 正常状态
        case EmptyData     //1 空数据状态
        case Fail          //2 请求失败状态
        case NoNetWork     //3 网络连接失败状态
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
        static var blankViewOffsetPointKey: Void?
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
    
    ///外部可控制整体View的中心点上下偏移位置 {0, 0}:表示上下居中显示, 默认居中显示
    var blankViewOffsetPoint: CGPoint? {
        get { (objc_getAssociatedObject(self, &AssociatedKeys.blankViewOffsetPointKey) as? CGPoint) }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.blankViewOffsetPointKey, newValue, .OBJC_ASSOCIATION_ASSIGN) }
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
    
    func networkReachable() -> Bool {
        return true
    }
    
    //MARK: - 添加空白页总方法入口
    func judgeBlankView(pageInfo: Dictionary<String, Any>?) {
        self.mj_header?.endRefreshing()
        self.mj_footer?.endRefreshing()
        
        if isEmptyDataContentView() { //页面没有数据
            //根据状态,显示背景提示Viwe
            var status: WXBlankTipViewStatus = .Fail
            
            if networkReachable() == false {
                status = .NoNetWork //显示没有网络提示
                
            } else if let _ = pageInfo {
                status = .EmptyData
            }
            //设置状态提示图片和文字
            showBlankTipWithStatus(status)
            
        } else { //页面有数据
            //移除页面上已有的提示视图
            removeBlankView()
            
            if let pageInfo = pageInfo, mj_footer != nil {
                //控制刷新控件显示的分页逻辑
                convertShowMjFooterView(pageInfo)
            }
        }
    }
    
    ///设置提示图片和文字
    func showBlankTipWithStatus(_ state: WXBlankTipViewStatus) {
        //先移除页面上已有的提示视图
        removeBlankView()
        
        let removeTipViewAndRefreshHeadBlock = { [weak self] in
            if let mj_header = self?.mj_header, mj_header.state == .idle {
                //1.先移除页面上已有的提示视图
                self?.removeBlankView()
                //2.开始走下拉请求
                mj_header.beginRefreshing()
            }
        }
        
        let blankPageViewBtnActionBlcok = { [weak self] in
            if let blankTipViewActionBlcok = self?.blankTipViewActionBlcok {
                //1. 先移除页面上已有的提示视图
                if (state != .EmptyData) {
                    self?.removeBlankView()
                }
                //2. 回调按钮点击事件
                blankTipViewActionBlcok(state)
            }
        }
        
        var tipString: String?
        var subTipString: String?
        var tipImage: UIImage?
        var actionBtnTitle: String?
        var actionBtnBlock: (() -> ())?
        
        switch state {
        case .NoNetWork:
            tipString = networkErrorTitle
            tipImage = networkErrorImage
            actionBtnTitle = networkErrorBtnTitle

            if blankTipViewActionBlcok != nil {
                actionBtnBlock = blankPageViewBtnActionBlcok
                
            } else if mj_header != nil {
                actionBtnBlock = removeTipViewAndRefreshHeadBlock
            } else {
                actionBtnTitle = nil;
            }
            
        case .EmptyData:
            tipString = emptyDataTitle
            tipImage = emptyDataImage
            subTipString = emptyDataSubTitle
            actionBtnTitle = emptyDataBtnTitle
            
            if blankTipViewActionBlcok != nil {
                actionBtnBlock = blankPageViewBtnActionBlcok
            } else {
                actionBtnTitle = nil;
            }
            
        case .Fail:
            tipString = requestFailTitle
            tipImage = requestFailImage
            actionBtnTitle = requestFailBtnTitle
            if blankTipViewActionBlcok != nil {
                actionBtnBlock = blankPageViewBtnActionBlcok
                
            } else if mj_header != nil {
                actionBtnBlock = removeTipViewAndRefreshHeadBlock
            } else {
                actionBtnTitle = nil;
            }
            
        default:
            return
        }
        
        guard let tipString = tipString, let tipImage = tipImage, let subTipString = subTipString, let actionBtnTitle = actionBtnTitle else { return }
        
        //防止重复添加
        removeBlankView()
        
        //需要显示的自定义提示view
        let tipBgView = WXBlankTipView()
        tipBgView.iconImage = tipImage;
        tipBgView.title = tipString
        tipBgView.subTitle = subTipString
        tipBgView.buttonTitle = actionBtnTitle
        tipBgView.actionBtnBlcok = actionBtnBlock
        tipBgView.tag = kBlankTipViewTag
        addSubview(tipBgView)
        
        if let offsetPoint = blankViewOffsetPoint, __CGPointEqualToPoint(offsetPoint, .zero) {
            tipBgView.contenViewOffsetPoint = blankViewOffsetPoint
        }
        
        tipBgView.snp.makeConstraints {
            $0.leading.top.equalTo(self)
            $0.height.equalTo(snp.height)
            $0.width.equalTo(snp.width).offset(-(contentInset.left + contentInset.right))
        }
        
        if let bgColor = backgroundColor {
            tipBgView.backgroundColor = bgColor
        }
    }
    
    
    ///控制Footer刷新控件是否显示
    func convertShowMjFooterView(_ pageInfo: Dictionary<String, Any> ) {
        let totalPage = pageInfo[kBlankViewTotalPageKey]
        let currentPage = pageInfo[kBlankViewCurrentPageKey]
        let dataArr = pageInfo[kBlankViewListKey]
        
        if totalPage != nil && currentPage != nil {
            if let totalPage = totalPage as? Int, let currentPage = currentPage as? Int {
                mj_header?.isHidden = (totalPage > currentPage)
            } else {
                mj_footer?.endRefreshingWithNoMoreData()
                mj_footer?.isHidden = true
            }
        } else if let dataArr = dataArr as? Array<Any> {
            if dataArr.count > 0 {
                mj_footer?.isHidden = false
            } else {
                mj_footer?.endRefreshingWithNoMoreData()
                mj_footer?.isHidden = true
            }
        } else {
            mj_footer?.isHidden = false
        }
    }
    
    
    /// 判断ScrollView页面上是否有数据
    /// - Returns: 是否有数据
    func isEmptyDataContentView() -> Bool {
        var isEmptyCell = true
        var sections = 1 //默认系统都只有1个sections
        
        if let tableView = self as? UITableView { ///当前页面是 UITableView子视图
            
            if tableView.tableHeaderView?.bounds.size.height ?? 0 > 0 ||
               tableView.tableFooterView?.bounds.size.height ?? 0 > 0 {
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
                            
                            if headerSize.width > 0 || headerSize.height > 0 {
                                isEmptyHeader = false
                                isEmptyCell = false
                                break
                            }
                        }
                    } else if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                        if flowLayout.headerReferenceSize.width > 0 {
                            isEmptyHeader = false
                            isEmptyCell = false
                        }
                    }
                    
                    // 如果Header没有高度还要判断Footer是否有高度
                    if isEmptyHeader, delegateFlowLayout.responds(to: #selector(delegateFlowLayout.collectionView(_:layout:referenceSizeForFooterInSection:))) {
                        
                        for idx in 0..<sections {
                            let footerSize = delegateFlowLayout.collectionView?(collectionView, layout: collectionView.collectionViewLayout, referenceSizeForFooterInSection: idx) ?? .zero
                            
                            if footerSize.width > 0 || footerSize.height > 0 {
                                isEmptyCell = false
                                break
                            }
                        }
                    }  else if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                        if flowLayout.footerReferenceSize.width > 0 {
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
