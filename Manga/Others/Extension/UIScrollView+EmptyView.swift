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

//当前提示view在父视图上的tag
let kEmptyTipViewTag: Int     = 1990

//判断表格数据空白页和分页的字段key
let kEmptyViewCurrentPageKey  = "curPage"
let kEmptyViewTotalPageKey    = "pageCount"
let kEmptyViewListKey         = "list"


/// 配置列表下拉分页字典
/// - Parameter dataInfo: 页面的接口数据, 可在此处统一包装分页字典, 注意:currPage、maxPage为后台约定好的统一页码参数key
/// - Returns: 请把返回的字典传给函数 func autoEmptyView(pageInfo: Dictionary<String, Any?>?)  的pageInfo参数来自动判断能否显示下一页控件
func configPageDict(_ dataInfo: Any?) -> Any? { // -> [String : Any]
    if let dataDict = dataInfo as? [String : Any] {
        return [ kEmptyViewCurrentPageKey : dataDict[kEmptyViewCurrentPageKey] as Any,
                 kEmptyViewTotalPageKey : dataDict[kEmptyViewTotalPageKey] as Any, ]
        
    } else if let dataArr = dataInfo as? [Any] {
        let currPage = (dataArr.count > 0) ? 1 : 0
        return [ kEmptyViewCurrentPageKey : currPage ,
                 kEmptyViewTotalPageKey : (currPage + 1) ]
    }
    return nil //[:]
}

///空白提示页
class WXEmptyTipView: UIView {
    
    //MARK: - InitMethod
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initLayoutSubView()
    }
    
    //MARK: - Setter Method
    var iconImage: UIImage? {
        didSet {
            guard let iconImage = iconImage else { return }
            tipImageView.image = iconImage
            tipImageView.isHidden = false
        }
    }
    var title: Any? {
        didSet {
            if let title = title as? String {
                tipLabel.text = title
                tipLabel.isHidden = false
                
            } else if let title = title as? NSAttributedString {
                tipLabel.attributedText = title
                tipLabel.isHidden = false
            }
        }
    }
    var subTitle: Any? {
        didSet {
            if let subTitle = subTitle as? String {
                subTitleLabel.text = subTitle
                subTitleLabel.isHidden = false
                
            } else if let subTitle = subTitle as? NSAttributedString {
                subTitleLabel.attributedText = subTitle
                subTitleLabel.isHidden = false
            }
            if !subTitleLabel.isHidden {
                subTitleLabel.snp.updateConstraints {
                    $0.top.equalTo(tipLabel.snp.bottom).offset(36)
                }
            }
        }
    }
    
    var buttonTitle: Any? {
        didSet {
            if let buttonTitle = buttonTitle as? String {
                actionBtn.setTitle(buttonTitle, for: .normal)
                actionBtn.isHidden = false
            } else if let buttonTitle = buttonTitle as? NSAttributedString {
                actionBtn.setAttributedTitle(buttonTitle, for: .normal)
                actionBtn.isHidden = false
            }
            if !actionBtn.isHidden {
                actionBtn.snp.updateConstraints {
                    $0.top.equalTo(subTitleLabel.snp.bottom).offset(20)
                    $0.height.equalTo(35)
                }
            }
        }
    }
    
    ///提示按钮点击事件
    var actionBtnBlcok: (()->()?)? = nil
    
    @objc func buttonAction() {
        if let actionBtnBlcok = actionBtnBlcok {
            actionBtnBlcok()
        }
    }
    
    var contenViewOffsetPoint: CGPoint? {
        didSet {
            guard let contenViewOffsetPoint = contenViewOffsetPoint else { return }
            contenView.snp.remakeConstraints {
                $0.centerX.equalTo(snp.centerX).offset(contenViewOffsetPoint.x);
                $0.centerY.equalTo(snp.centerY).offset(contenViewOffsetPoint.y);
                $0.width.equalTo(snp.width)
            }
        }
    }
    
    private func initLayoutSubView() {
        addSubview(contenView)
        contenView.snp.makeConstraints {
            $0.centerX.equalTo(snp.centerX)
            $0.centerY.equalTo(snp.centerY)
            $0.width.equalTo(snp.width)
        }
        contenView.addSubview(tipImageView)
        tipImageView.snp.makeConstraints {
            $0.top.equalTo(contenView.snp.top)
            $0.centerX.equalTo(contenView.snp.centerX)
        }
        contenView.addSubview(tipLabel)
        tipLabel.snp.makeConstraints {
            $0.top.equalTo(tipImageView.snp.bottom).offset(16);
            $0.leading.equalTo(contenView.snp.leading).offset(12);
            $0.trailing.equalTo(contenView.snp.trailing).offset(-12);
        }
        contenView.addSubview(subTitleLabel)
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(tipLabel.snp.bottom).offset(0);
            $0.leading.equalTo(contenView.snp.leading).offset(12);
            $0.trailing.equalTo(contenView.snp.trailing).offset(-12);
        }
        contenView.addSubview(actionBtn)
        actionBtn.snp.makeConstraints {
            $0.top.equalTo(subTitleLabel.snp.bottom).offset(0);
            $0.centerX.equalTo(contenView.snp.centerX);
            $0.height.equalTo(0);
            $0.bottom.equalTo(contenView.snp.bottom);
        }
    }
    
    //MARK: - Getter UI
    
    //提示背景主视图
    private lazy var contenView: UIView = {
        let contenView = UIView()
        contenView.backgroundColor = .clear
        return contenView
    }()
    //提示图片
    private lazy var tipImageView: UIImageView = {
        let tipImageView = UIImageView()
        tipImageView.backgroundColor = .clear
        tipImageView.contentMode = .scaleAspectFit
        tipImageView.isHidden = true
        return tipImageView
    }()
    //提示文案
    private lazy var tipLabel: UILabel = {
        let tipLabel = UILabel()
        tipLabel.backgroundColor = .clear
        tipLabel.font = UIFont.systemFont(ofSize: 14)
        tipLabel.textColor = .hex("0x999999")
        tipLabel.textAlignment = .center
        tipLabel.adjustsFontSizeToFitWidth = true
        tipLabel.numberOfLines = 0
        tipLabel.isHidden = true
        return tipLabel
    }()
    //提示描述文案
    private lazy var subTitleLabel: UILabel = {
        let tipLabel = UILabel()
        tipLabel.backgroundColor = .clear
        tipLabel.font = UIFont.systemFont(ofSize: 14)
        tipLabel.textColor = UIColor(r: 153, g: 153, b: 153, a: 1)
        tipLabel.textAlignment = .center
        tipLabel.adjustsFontSizeToFitWidth = true
        tipLabel.numberOfLines = 0
        tipLabel.isHidden = true
        return tipLabel
    }()
    //点击事件按钮
    private lazy var actionBtn: UIButton = {
        let mainColor = UIColor.hex("0x999999")
        let actionBtn = UIButton(type: .custom)
        actionBtn.setTitleColor(mainColor, for: .normal)
        actionBtn.setTitleColor(mainColor.withAlphaComponent(0.7), for: .highlighted)
        actionBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        actionBtn.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        actionBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 28, bottom: 0, right: 28)
        actionBtn.titleLabel?.numberOfLines = 0
        actionBtn.layer.borderWidth = 1
        actionBtn.layer.borderColor = mainColor.cgColor
        actionBtn.layer.cornerRadius = 35/2
        actionBtn.layer.masksToBounds = true
        actionBtn.isHidden = true
        return actionBtn
    }()
}

extension UIScrollView {
    
    enum WXEmptyTipViewStatus {
        ///0 正常状态
        case Normal
        ///1 空数据状态
        case EmptyData
        ///2 请求失败状态
        case Fail
        ///3 网络无法状态
        case NoNetWork
    }
    fileprivate struct AssociatedKeys {
        static var emptyDataTitleKey: Void?
        static var emptyDataSubTitleKey: Void?
        static var emptyDataImageKey: Void?
        static var emptyDataBtnTitleKey: Void?
        static var loadFailTitleKey: Void?
        static var loadFailImageKey: Void?
        static var loadFailBtnTitleKey: Void?
        static var networkErrorTitleKey: Void?
        static var networkErrorImageKey: Void?
        static var networkErrorBtnTitleKey: Void?
        static var emptyViewOffsetPointKey: Void?
        static var emptyTipViewActionBlcokKey: Void?
    }
    
    ///空数据标题
    var emptyDataTitle: String {
        get { (objc_getAssociatedObject(self, &AssociatedKeys.emptyDataTitleKey) as? String) ?? "暂无可用数据" }
        set { objc_setAssociatedObject(self, &AssociatedKeys.emptyDataTitleKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    ///空数据副标题
    var emptyDataSubTitle: String? {
        get { (objc_getAssociatedObject(self, &AssociatedKeys.emptyDataSubTitleKey) as? String) }
        set { objc_setAssociatedObject(self, &AssociatedKeys.emptyDataSubTitleKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    ///空数据图片
    var emptyDataImage: UIImage? {
        get { (objc_getAssociatedObject(self, &AssociatedKeys.emptyDataImageKey) as? UIImage) ?? UIImage(named: "empty_data_tip") }
        set { objc_setAssociatedObject(self, &AssociatedKeys.emptyDataImageKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    ///空数据按钮标题
    var emptyDataBtnTitle: String? {
        get { (objc_getAssociatedObject(self, &AssociatedKeys.emptyDataBtnTitleKey) as? String) }
        set { objc_setAssociatedObject(self, &AssociatedKeys.emptyDataBtnTitleKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    ///请求失败文字
    var loadFailTitle: String {
        get { (objc_getAssociatedObject(self, &AssociatedKeys.loadFailTitleKey) as? String) ?? "加载失败,请稍后再试" }
        set { objc_setAssociatedObject(self, &AssociatedKeys.loadFailTitleKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    ///请求失败图片
    var loadFailImage: UIImage? {
        get { (objc_getAssociatedObject(self, &AssociatedKeys.loadFailImageKey) as? UIImage) ?? UIImage(named: "load_fail_tip") }
        set { objc_setAssociatedObject(self, &AssociatedKeys.loadFailImageKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    ///请求失败按钮
    var loadFailBtnTitle: String {
        get { (objc_getAssociatedObject(self, &AssociatedKeys.loadFailBtnTitleKey) as? String) ?? "刷新" }
        set { objc_setAssociatedObject(self, &AssociatedKeys.loadFailBtnTitleKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    ///网络连接失败文字
    var networkErrorTitle: String {
        get { (objc_getAssociatedObject(self, &AssociatedKeys.networkErrorTitleKey) as? String) ?? "网络连接失败,请检查网络" }
        set { objc_setAssociatedObject(self, &AssociatedKeys.networkErrorTitleKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    ///网络连接失败图片
    var networkErrorImage: UIImage? {
        get { (objc_getAssociatedObject(self, &AssociatedKeys.networkErrorImageKey) as? UIImage) ?? UIImage(named: "network_error_tip") }
        set { objc_setAssociatedObject(self, &AssociatedKeys.networkErrorImageKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    ///网络连接失败按钮
    var networkErrorBtnTitle: String? {
        get { (objc_getAssociatedObject(self, &AssociatedKeys.networkErrorBtnTitleKey) as? String) ?? "刷新" }
        set { objc_setAssociatedObject(self, &AssociatedKeys.networkErrorBtnTitleKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    
    ///外部可控制整体View的中心点上下偏移位置 {0, 0}:表示上下居中显示, 默认居中显示
    var emptyViewOffsetPoint: CGPoint? {
        get { (objc_getAssociatedObject(self, &AssociatedKeys.emptyViewOffsetPointKey) as? CGPoint) }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.emptyViewOffsetPointKey, newValue, .OBJC_ASSOCIATION_ASSIGN) }
    }
    
    typealias emptyTipViewBlockType = (WXEmptyTipViewStatus) -> ()
    
    ///按钮点击的事件
    var emptyTipViewActionBlcok: emptyTipViewBlockType? {
        get { objc_getAssociatedObject(self, &AssociatedKeys.emptyTipViewActionBlcokKey) as? emptyTipViewBlockType }
        set { objc_setAssociatedObject(self, &AssociatedKeys.emptyTipViewActionBlcokKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    
    //MARK: - 表格的上下拉刷新控件
    
    typealias WXRefreshingBlock = () -> ()
    
    /// 快捷添加表格的上下拉刷新控件方法
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
                self?.removeEmptyView()
                
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
    
    //MARK: - 自动添加列表空白页
    
    /// 为列表判断有无数据来自动添加空白提示页
    /// - Parameter autoEmptyViewInfo:
    /// 1.列表有分页逻辑: 请传入数据页码字典; (字典配置可调用快捷方法: func configPageDict(_ dataInfo: Any?)
    /// 2.列表没有分页逻辑: 列表有数据随便传什么; 没有数据传空:nil
    func reloadData(autoEmptyViewInfo: Any?) {
        if let tableView = self as? UITableView {
            tableView.reloadData()
            
            let pageDict = configPageDict(autoEmptyViewInfo)
            autoEmptyView(pageInfo: pageDict as? Dictionary<String, Any?>)
            
        } else if let collectionView = self as? UICollectionView {
            collectionView.reloadData()
            
            let pageDict = configPageDict(autoEmptyViewInfo)
            autoEmptyView(pageInfo: pageDict as? Dictionary<String, Any?>)
        }
    }
    
    /// 为列表判断有无数据来自动添加空白提示页
    /// - Parameter pageInfo:
    /// 1.列表有分页逻辑: 请传入数据页码字典; (字典配置可调用快捷方法: func configPageDict(_ dataInfo: Any?)
    /// 2.列表没有分页逻辑: 列表有数据随便传什么; 没有数据传空:nil
    fileprivate func autoEmptyView(pageInfo: Dictionary<String, Any?>?) {
        self.mj_header?.endRefreshing()
        self.mj_footer?.endRefreshing()
        
        if isEmptyDataContentView() { //页面没有数据
            //根据状态,显示背景提示Viwe
            var status: WXEmptyTipViewStatus = .Fail
            
            if networkReachable() == false {
                status = .NoNetWork //显示没有网络提示
                
            } else if let _ = pageInfo {
                status = .EmptyData
            }
            //设置状态提示图片和文字
            showEmptyTipWithStatus(status)
            
        } else { //页面有数据
            //移除页面上已有的提示视图
            removeEmptyView()
            
            if let pageInfo = pageInfo, mj_footer != nil {
                //控制刷新控件显示的分页逻辑
                convertShowMjFooterView(pageInfo)
            }
        }
    }
    
    //MARK: - (内部判断逻辑,外部请忽略以下方法)
    
    ///移除页面上已有的空白提示页
    fileprivate func removeEmptyView() {
        for tmpView in subviews {
            if tmpView is WXEmptyTipView, tmpView.tag == kEmptyTipViewTag {
                tmpView.removeFromSuperview()
            }
        }
    }
    
    ///网络是否可用
    fileprivate func networkReachable() -> Bool {
        return reachabilityNetwork?.isReachable ?? true
    }
    
    ///设置提示图片和文字
    fileprivate func showEmptyTipWithStatus(_ state: WXEmptyTipViewStatus) {
        //先移除页面上已有的提示视图
        removeEmptyView()
        
        let removeTipViewAndRefreshHeadBlock = { [weak self] in
            if let mj_header = self?.mj_header, mj_header.state == .idle {
                //1.先移除页面上已有的提示视图
                self?.removeEmptyView()
                //2.开始走下拉请求
                mj_header.beginRefreshing()
            }
        }
        
        let emptyPageViewBtnActionBlcok = { [weak self] in
            if let emptyTipViewActionBlcok = self?.emptyTipViewActionBlcok {
                //1. 先移除页面上已有的提示视图
                if (state != .EmptyData) {
                    self?.removeEmptyView()
                }
                //2. 回调按钮点击事件
                emptyTipViewActionBlcok(state)
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
            if emptyTipViewActionBlcok != nil {
                actionBtnBlock = emptyPageViewBtnActionBlcok
                
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
            if emptyTipViewActionBlcok != nil {
                actionBtnBlock = emptyPageViewBtnActionBlcok
            } else {
                actionBtnTitle = nil;
            }
            
        case .Fail:
            tipString = loadFailTitle
            tipImage = loadFailImage
            actionBtnTitle = loadFailBtnTitle
            if emptyTipViewActionBlcok != nil {
                actionBtnBlock = emptyPageViewBtnActionBlcok
                
            } else if mj_header != nil {
                actionBtnBlock = removeTipViewAndRefreshHeadBlock
            } else {
                actionBtnTitle = nil;
            }
            
        default:
            return
        }
        if tipString == nil, tipImage == nil, subTipString == nil, actionBtnTitle == nil { return }
        
        //防止重复添加
        removeEmptyView()
        
        //需要显示的自定义提示view
        let tipBgView = WXEmptyTipView(frame: .zero)
        tipBgView.iconImage = tipImage;
        tipBgView.title = tipString
        tipBgView.subTitle = subTipString
        tipBgView.buttonTitle = actionBtnTitle
        tipBgView.actionBtnBlcok = actionBtnBlock
        tipBgView.tag = kEmptyTipViewTag
        tipBgView.backgroundColor = backgroundColor ?? .white
        addSubview(tipBgView)
        
        tipBgView.snp.makeConstraints {
            $0.leading.equalTo(snp.leading);
            $0.top.equalTo(snp.top);
            $0.height.equalTo(snp.height);
            $0.width.equalTo(snp.width).offset(-(contentInset.left + contentInset.right));
        }
        
        if let offsetPoint = emptyViewOffsetPoint, !__CGPointEqualToPoint(offsetPoint, .zero) {
            tipBgView.contenViewOffsetPoint = offsetPoint
        }
    }
    
    
    /// 判断ScrollView页面上是否有数据
    /// - Returns: 是否有数据
    fileprivate func isEmptyDataContentView() -> Bool {
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
                if sections == 0 {
                    return true
                }
                for idx in 0..<sections {
                    let rows = dataSource.tableView(tableView, numberOfRowsInSection: idx)
                    if rows > 0 {
                        return false
                    }
                }
            }
            // 如果每个Cell没有数据源, 则还需要判断Header和Footer高度是否为0
            if let delegate = tableView.delegate {
                
                //检查是否有自定义HeaderView
                if delegate.responds(to: #selector(delegate.tableView(_:heightForHeaderInSection:))) {
                    for idx in 0..<sections {
                        let headerHeight = delegate.tableView?(tableView, heightForHeaderInSection: idx) ?? 0
                        if headerHeight > 1.0 {
                            return false
                        }
                    }
                } else if tableView.sectionHeaderHeight > 0 || tableView.estimatedSectionHeaderHeight > 0 {
                    return false
                }
                
                // 如果Header没有高度还要判断Footer是否有高度
                if delegate.responds(to: #selector(delegate.tableView(_:heightForFooterInSection:))) {
                    for idx in 0..<sections {
                        let footerHeight = delegate.tableView?(tableView, heightForFooterInSection: idx) ?? 0
                        if footerHeight > 1.0 {
                            return false
                        }
                    }
                } else if tableView.sectionFooterHeight > 0 || tableView.estimatedSectionFooterHeight > 0 {
                    return false
                }
            }
            
        } else if let collectionView = self as? UICollectionView { ///当前页面是 UICollectionView子视图
            
            if let dataSource = collectionView.dataSource {
                if dataSource.responds(to: #selector(dataSource.numberOfSections(in:))) {
                    sections = dataSource.numberOfSections?(in: collectionView) ?? 1
                }
                if sections == 0 {
                    return true
                }
                for idx in 0..<sections {
                    let items = dataSource.collectionView(collectionView, numberOfItemsInSection: idx)
                    if items > 0 {
                        return false
                    }
                }
            }
            // 如果每个ItemCell没有数据源, 则还需要判断Header和Footer高度是否为0
            if let delegate = collectionView.delegate {
                
                ///<UICollectionViewDelegateFlowLayout>
                if let delegateFlowLayout = delegate as? UICollectionViewDelegateFlowLayout {
                    
                    //检查是否有自定义HeaderView
                    if delegateFlowLayout.responds(to: #selector(delegateFlowLayout.collectionView(_:layout:referenceSizeForHeaderInSection:))) {
                        
                        for idx in 0..<sections {
                            let headerSize = delegateFlowLayout.collectionView?(collectionView, layout: collectionView.collectionViewLayout, referenceSizeForHeaderInSection: idx) ?? .zero
                            
                            if headerSize.width > 0 || headerSize.height > 0 {
                                return false
                            }
                        }
                    } else if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                        if flowLayout.headerReferenceSize.width > 0 {
                            return false
                        }
                    }
                    
                    // 如果Header没有高度还要判断Footer是否有高度
                    if delegateFlowLayout.responds(to: #selector(delegateFlowLayout.collectionView(_:layout:referenceSizeForFooterInSection:))) {
                        
                        for idx in 0..<sections {
                            let footerSize = delegateFlowLayout.collectionView?(collectionView, layout: collectionView.collectionViewLayout, referenceSizeForFooterInSection: idx) ?? .zero
                            
                            if footerSize.width > 0 || footerSize.height > 0 {
                                return false
                            }
                        }
                    }  else if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                        if flowLayout.footerReferenceSize.width > 0 {
                            return false
                        }
                    }
                }
                if !collectionView.collectionViewLayout.collectionViewContentSize.equalTo(.zero) {
                    return false
                }
            }
        } else { ///当前页面是 UIScrollView 子视图
            for subView in subviews {
                if subView.isHidden == false || subView.alpha != 0.0 {
                    return false
                }
            }
        }
        return true
    }
    
    ///控制Footer刷新控件是否显示
    fileprivate func convertShowMjFooterView(_ pageInfo: Dictionary<String, Any?> ) {
        let currentPage = pageInfo[kEmptyViewCurrentPageKey]
        let totalPage   = pageInfo[kEmptyViewTotalPageKey]
        let dataArr     = pageInfo[kEmptyViewListKey]
        
        if let totalPage = totalPage as? Int, let currentPage = currentPage as? Int {
            if totalPage > currentPage {
                mj_footer?.isHidden = false
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
            //mj_footer?.isHidden = false
        }
    }
    
}
