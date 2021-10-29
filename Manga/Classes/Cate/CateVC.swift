//
//  CateVC.swift
//  Manga
//
//  Created by 610582 on 2021/1/30.
//

import UIKit
import SnapKit
import Moya
import MJRefresh
import KakaJSON
import WXNetworkingSwift

class CateVC: BaseVC {
    
    private var rankingList = [RankingModel]()
    
    lazy var collectionView: UICollectionView = {
        let lt = UICollectionViewFlowLayout()
        lt.minimumLineSpacing = 10
        lt.minimumInteritemSpacing = 10
        lt.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        let width = floor(Double( UIScreen.main.bounds.width - 40.0 ) / 3.0)
        lt.itemSize = CGSize(width: width, height: 120)
        let cw = UICollectionView(frame: CGRect.zero, collectionViewLayout: lt)
        cw.backgroundColor = UIColor.white
        cw.delegate = self
        cw.dataSource = self
        cw.register(URankCCell.self, forCellWithReuseIdentifier: NSStringFromClass(URankCCell.self))
        return cw
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadListData()
        addRefreshKit()
    }
    
    func addRefreshKit() {
        collectionView.mj_header = MJRefreshNormalHeader {
            [weak self] in
            self?.loadListData()
        }
    }
    
    override func initSubView() {
        view.addSubview(collectionView)
    }
    
    override func layoutSubView() {
        collectionView.snp.makeConstraints { $0.edges.equalTo(self.view) }
    }
    
    func loadListData() {
        let url: String = "http://app.u17.com/v3/appV3_3/ios/phone/sort/mobileCateList"
        let request = WXRequestApi(url, method: .get, parameters: nil)
        request.loadingSuperView = view
        request.successStatusMap = (key: "code",  value: "1")
        request.parseModelMap = (parseKey: "data.returnData.rankingList" , modelType: RankingModel.self)
        
        request.startRequest { [weak self] (responseModel) in
            self?.rankingList = (responseModel.parseKeyPathModel as? [RankingModel]) ?? []
            self?.collectionView.reloadData(autoEmptyViewInfo: self?.rankingList)
        }
    }
}

extension CateVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rankingList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: URankCCell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(URankCCell.self), for: indexPath) as! URankCCell
        cell.model = rankingList[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let model = rankingList[indexPath.item]
        let detailVC = UCateDetailVC()
        detailVC.hidesBottomBarWhenPushed = true
        detailVC.title = model.sortName
        detailVC.argCon = model.argCon
        detailVC.argName = model.argName ?? ""
        detailVC.argValue = model.argValue
        navigationController?.pushViewController(detailVC, animated: true)
        
    }
}
