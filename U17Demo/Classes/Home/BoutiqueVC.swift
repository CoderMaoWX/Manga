//
//  BoutiqueVC.swift
//  U17Demo
//
//  Created by 610582 on 2021/2/20.
//

import UIKit
import Alamofire
import KakaJSON
import SnapKit

class BoutiqueVC: BaseVC {
    
    var comicLists :[ComicListModel] = []
    
    lazy var collectionView: UICollectionView = {
        let fl = UICollectionViewFlowLayout()
        fl.minimumLineSpacing = 10
        fl.minimumInteritemSpacing = 10
        
        let width = floor((UIScreen.main.bounds.width - 10.0) / 2.0)
        fl.itemSize = CGSize(width: width, height: 160)
        fl.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 44)
        fl.footerReferenceSize = CGSize.zero
        
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: fl)
        cv.backgroundColor = .white
        cv.delegate = self
        cv.dataSource = self
        cv.register(BoutiqueCell.self, forCellWithReuseIdentifier: NSStringFromClass(BoutiqueCell.self))
       
        cv.register(UComicCHead.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: NSStringFromClass(UComicCHead.self))
        
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
        collectionView.snp.makeConstraints { $0.edges.equalTo(view) }
    }
    
    func loadData() {
        let url = "http://app.u17.com/v3/appV3_3/ios/phone/comic/boutiqueListNew"
        let param: [String : Any] = ["sexType" : 1]
        AF.request(url, parameters: param).responseJSON {
            [weak self] (resultData) in
            
            switch resultData.result {
            case .success(let json):
                let dataDict = ((json as? NSDictionary)?["data"] as? NSDictionary)?["returnData"]
                let listModel = model(from: (dataDict as! NSDictionary), BoutiqueListModel.self)
                self?.comicLists = listModel?.comicLists ?? []
                print("主页请求成功:" , self?.comicLists as Any)
                self?.collectionView.reloadData()
                break
            case .failure(let error):
                print("主页请求失败:", error)
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
            let reusableView: UComicCHead = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: NSStringFromClass(UComicCHead.self), for: indexPath) as! UComicCHead
            reusableView.model = comicLists[indexPath.section]
            reusableView.touchMoreAction {
                [weak self] in
                self?.collectionView.reloadData()
            }
            return reusableView
        } else {
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: BoutiqueCell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(BoutiqueCell.self), for: indexPath) as! BoutiqueCell
     
        cell.model = comicLists[indexPath.section].comics?[indexPath.item]
        return cell
    }
}
