//
//  MineVC.swift
//  Manga
//
//  Created by 610582 on 2021/1/30.
//

import UIKit
import KakaJSON
import SnapKit
import WXNetworkingSwift

class MineVC: BaseVC {
    
    var dataArray: [MineListModel] = []
    
    lazy var collectionView: UICollectionView = {
        let fl = UICollectionViewFlowLayout()
        fl.minimumLineSpacing = 10
        fl.minimumInteritemSpacing = 10
//        let w = UIScreen.main.bounds.size.width / 4.0
        fl.itemSize = CGSize(width: 70, height: 80)
        fl.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: fl)
        cv.showsVerticalScrollIndicator = false
        cv.backgroundColor = .white
        cv.delegate = self
        cv.dataSource = self
        cv.register(MineItemCCell.self, forCellWithReuseIdentifier: NSStringFromClass(MineItemCCell.self))
        
        let HeaderView = UINib(nibName: "MineCenterHeaderView", bundle: nil)
        cv.register(HeaderView, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "MineCenterHeaderView")
        
//        cv.register(MineCenterHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: NSStringFromClass(MineCenterHeaderView.self))
        
        cv.register(MineCenterTextHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: NSStringFromClass(MineCenterTextHeaderView.self))

        cv.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: NSStringFromClass(UICollectionReusableView.self))
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    override func initSubView() {
        view.addSubview(collectionView)
    }
    
    override func layoutSubView() {
        collectionView.snp.makeConstraints {
            $0.edges.equalTo(UIEdgeInsets.zero)
        }
    }
   
    func loadData() {
        var dict: [String: String] = [:]
        dict["_"] = "1617699649"
        dict["_brand"] = "Apple"
        dict["_carrier"] = "%E4%B8%AD%E5%9B%BD%E7%A7%BB%E5%8A%A8"
        dict["_channel"] = "Appstore"
        dict["_idfa"] = "1809AD50-995C-4F59-AB73-00DD0384D5A4"
        dict["_locale"] = "CN"
        dict["_mg_language"] = "zh_tw"
        dict["_model"] = "iPhone13,2"
        dict["_ov"] = "14.2"
        dict["_package"] = "com.truecolor.Manga"
        dict["_resolution"] = "1170,2532"
        dict["_udid"] = "fb67defc4ff0112786efa581128342fd"
        dict["_v"] = "3.9.2"
        dict["follow"] = "0"
        dict["id"] = "1"
        dict["page"] = "0"
        dict["sort_type"] = "hot"
        
        let url = "https://manga.1kxun.mobi/api/mycenter/getList"
        let request = WXRequestApi(url, method: .get, parameters: dict)
        request.loadingSuperView = view
        request.successStatusMap = (key: "status",  value: "success")
        request.parseModelMap = (parseKey: "data" , modelType: MineListModel.self)

        request.startRequest { [weak self] (responseModel) in
            var listModel = (responseModel.parseKeyPathModel as? [MineListModel]) ?? []
            listModel.insert(contentsOf: self?.defaultUserItem() ?? [], at: 0)
            self?.dataArray = listModel
            self?.collectionView.reloadData(autoEmptyViewInfo: self?.dataArray)
        }
    }
    
    func defaultUserItem() -> [MineListModel] {
        let itemArr = [
            ["title" : "充值",
             "click_url" : "https://manga.1kxun.mobi/web/rechargeRice?_token=102-0cb76e73703e2a94ee617b84a90f4a07&_udid=fb67defc4ff0112786efa581128342fd&access_token=102-0cb76e73703e2a94ee617b84a90f4a07&_brand=Apple&_v=4.0.0&_model=iPhone13%2C2&_idfa=1809AD50-995C-4F59-AB73-00DD0384D5A4&_package=com.truecolor.Manga&_mg_language=zh_tw&_carrier=%E4%B8%AD%E5%9B%BD%E7%A7%BB%E5%8A%A8&_locale=CN&_ov=14.2&_channel=Appstore&_=1618825403&_resolution=1170%2C2532",
             "image" : "mymanga_stablecell_topup"],
            
            ["title" : "我的消息",
             "click_url" : "",
             "image" : "mymanga_stablecell_message"],
            
            ["title" : "我的卷包",
             "click_url" : "http://manga.1kxun.mobi/web/myticket?_token=102-0cb76e73703e2a94ee617b84a90f4a07&_udid=fb67defc4ff0112786efa581128342fd&access_token=102-0cb76e73703e2a94ee617b84a90f4a07&_brand=Apple&_v=4.0.0&_model=iPhone13%2C2&type=1&_idfa=1809AD50-995C-4F59-AB73-00DD0384D5A4&_package=com.truecolor.Manga&_mg_language=zh_tw&_carrier=%E4%B8%AD%E5%9B%BD%E7%A7%BB%E5%8A%A8&_locale=CN&_ov=14.2&_channel=Appstore&_=1618825497&_resolution=1170%2C2532",
             "image" : "mymanga_stablecell_ticket"],
            
            ["title" : "今日任务",
             "click_url" : "http://points.1kxun.mobi/web/tasks/index?_token=102-0cb76e73703e2a94ee617b84a90f4a07&_udid=fb67defc4ff0112786efa581128342fd&access_token=102-0cb76e73703e2a94ee617b84a90f4a07&app_id=2&_brand=Apple&_v=4.0.0&_model=iPhone13%2C2&_idfa=1809AD50-995C-4F59-AB73-00DD0384D5A4&_package=com.truecolor.Manga&_mg_language=zh_tw&_carrier=%E4%B8%AD%E5%9B%BD%E7%A7%BB%E5%8A%A8&_locale=CN&_ov=14.2&_channel=Appstore&_=1618825514&_resolution=1170%2C2532",
             "image" : "mymanga_stablecell_task"],
            
            ["title" : "福利",
             "click_url" : "http://manga.1kxun.mobi/web/welfare?_token=102-0cb76e73703e2a94ee617b84a90f4a07&_udid=fb67defc4ff0112786efa581128342fd&access_token=102-0cb76e73703e2a94ee617b84a90f4a07&_brand=Apple&_v=4.0.0&_model=iPhone13%2C2&_idfa=1809AD50-995C-4F59-AB73-00DD0384D5A4&_package=com.truecolor.Manga&_mg_language=zh_tw&_carrier=%E4%B8%AD%E5%9B%BD%E7%A7%BB%E5%8A%A8&_locale=CN&_ov=14.2&_channel=Appstore&_=1618825533&_resolution=1170%2C2532",
             "image" : "mymanga_stablecell_welfare"],
            
            ["title" : "我的购买",
             "click_url" : "http://manga.1kxun.mobi/web/expenses?_token=102-0cb76e73703e2a94ee617b84a90f4a07&_udid=fb67defc4ff0112786efa581128342fd&access_token=102-0cb76e73703e2a94ee617b84a90f4a07&_brand=Apple&_v=4.0.0&_model=iPhone13%2C2&_idfa=1809AD50-995C-4F59-AB73-00DD0384D5A4&_package=com.truecolor.Manga&_mg_language=zh_tw&_carrier=%E4%B8%AD%E5%9B%BD%E7%A7%BB%E5%8A%A8&_locale=CN&_ov=14.2&_channel=Appstore&_=1618825552&_resolution=1170%2C2532",
             "image" : "mymanga_stablecell_mybuy"],
            
            ["title" : "邀请好友",
             "click_url" : "",
             "image" : "mymanga_stablecell_invite"],
            
            ["title" : "意见反馈",
             "click_url" : "http://feedbacks.1kxun.mobi/web/feedbacks/index?_token=102-0cb76e73703e2a94ee617b84a90f4a07&_udid=fb67defc4ff0112786efa581128342fd&access_token=102-0cb76e73703e2a94ee617b84a90f4a07&_brand=Apple&_v=4.0.0&_model=iPhone13%2C2&from=my_manga&_idfa=1809AD50-995C-4F59-AB73-00DD0384D5A4&_package=com.truecolor.Manga&_mg_language=zh_tw&_carrier=%E4%B8%AD%E5%9B%BD%E7%A7%BB%E5%8A%A8&_locale=CN&_ov=14.2&_channel=Appstore&_=1618825566&_resolution=1170%2C2532",
             "image" : "mymanga_stablecell_feedback"],
        ]
        
        var listModel = MineListModel()
        listModel.title = ""
        listModel.list = modelArray(from: itemArr, MineItemModel.self)
        return [listModel]
    }
}

extension MineVC: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: UIScreen.main.bounds.size.width, height: 200)
        } else {
            return CGSize(width: UIScreen.main.bounds.size.width, height: 40)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let model: MineListModel = dataArray[section]
        return model.list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let model: MineListModel = dataArray[indexPath.section]
            
            if indexPath.section == 0 {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MineCenterHeaderView", for: indexPath) as! MineCenterHeaderView
                return header
            } else {
                let titleHeader = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: NSStringFromClass(MineCenterTextHeaderView.self), for: indexPath) as! MineCenterTextHeaderView
                titleHeader.title = model.title
                return titleHeader
            }
        }
        return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: NSStringFromClass(UICollectionReusableView.self), for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(MineItemCCell.self), for: indexPath) as! MineItemCCell
        let model: MineListModel = dataArray[indexPath.section]
        cell.model = model.list[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sectionModel: MineListModel = dataArray[indexPath.section]
        let model: MineItemModel = sectionModel.list[indexPath.item]
        
        guard let URL = model.click_url else { return }
        if URL.isEmpty {
            return
        }
        let webVC = WebVC(url: URL)
        webVC.title = model.title
        navigationController?.pushViewController(webVC, animated: true)
    }
    
}
