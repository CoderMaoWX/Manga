//
//  BoutiqueVC.swift
//  Manga
//
//  Created by 610582 on 2021/2/20.
//

import UIKit
import Alamofire
import KakaJSON
//import SnapKit
import SwiftyJSON
import SVProgressHUD
import Reusable

class BoutiqueVC: BaseVC {
    
    var comicLists :[ComicListModel] = []
    
    lazy var collectionView: UICollectionView = {
        let fl = UICollectionViewFlowLayout()
        fl.minimumLineSpacing = 10
        fl.minimumInteritemSpacing = 10
        
        let width = floor((UIScreen.main.bounds.width - 10.0) / 2.0)
        fl.itemSize = CGSize(width: width, height: 160)
        fl.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 44)
        fl.footerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 8)
        
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: fl)
        cv.backgroundColor = .background
        cv.delegate = self
        cv.dataSource = self
        cv.register(cellType: BoutiqueCell.self)
        cv.register(supplementaryViewType: UComicCHead.self, ofKind: UICollectionView.elementKindSectionHeader)
        cv.register(supplementaryViewType: UComicCFoot.self, ofKind: UICollectionView.elementKindSectionFooter)
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
//        collectionView.snp.makeConstraints { $0.edges.equalTo(view) }
        collectionView.mg.makeConstraints { $0.edges.equalTo(view) }
    }
    
    func loadData() {
        SVProgressHUD.show()
        let url = "http://app.u17.com/v3/appV3_3/ios/phone/comic/boutiqueListNew"
        let param: [String : Any] = ["sexType" : 1]
        AF.request(url, parameters: param).responseJSON {
            [weak self] (resultData) in
            SVProgressHUD.dismiss()
            
            switch resultData.result {
            case .success(let json):
                print("主页请求成功响应Json", JSON(json));
                let dataDict = JSON(json)["data"]["returnData"].dictionaryObject                
                let listModel = model(from: dataDict!, BoutiqueListModel.self)
                self?.comicLists = listModel.comicLists ?? []
                self?.collectionView.reloadData()
                if self?.comicLists.count == 0 {
                    SVProgressHUD.showError(withStatus: "数据刷新失败")
                }
                break
            case .failure(let error):
                print("主页请求失败:", error)
                SVProgressHUD.showError(withStatus: "数据刷新失败")
                break
            }
        }
    }
}

extension BoutiqueVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        comicLists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        comicLists[section].comics?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath, viewType: UComicCHead.self)
            reusableView.model = comicLists[indexPath.section]
            reusableView.touchMoreAction {
                collectionView.reloadData()
            }
            return reusableView
        } else {
            let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath, viewType: UComicCFoot.self)
            reusableView.backgroundColor = .groupTableViewBackground
            return reusableView
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: BoutiqueCell.self)
        cell.model = comicLists[indexPath.section].comics?[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = comicLists[indexPath.section].comics?[indexPath.item]

    }
}
