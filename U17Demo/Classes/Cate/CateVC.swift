//
//  CateVC.swift
//  U17Demo
//
//  Created by 610582 on 2021/1/30.
//

import UIKit
import SnapKit
import Moya
import Alamofire
import KakaJSON

class CateVC: BaseVC {
    
    lazy var collectionView: UICollectionView = {
        let lt = UICollectionViewFlowLayout()
        lt.minimumLineSpacing = 10
        lt.minimumInteritemSpacing = 10
        let cw = UICollectionView(frame: CGRect.zero, collectionViewLayout: lt)
        cw.backgroundColor = UIColor.white
        cw.delegate = self
        cw.dataSource = self
        
        cw .register(URankCCell.self, forCellWithReuseIdentifier: NSStringFromClass(URankCCell.self))
        
        return cw
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getMobileCateList()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        getMobileCateList()
    }
    
    func getMobileCateList() {
        let weatherUrl: String = "http://app.u17.com/v3/appV3_3/ios/phone/sort/mobileCateList"
        
        AF.request(weatherUrl, method: HTTPMethod.get, parameters: nil).responseJSON {
            (response) in
            
            switch response.result {
            case .success(let json):
                if let data = (json as! NSDictionary)["data"] as? NSDictionary {
                    if let returnData = data["returnData"] {
                        let cat = (returnData as! NSDictionary).kj.model(CateListModel.self)
                        print(cat!)
                    }
                }
                break
            case .failure(let error):
                print("error: \(error)")
                break
            
            }
        }
    }
    
    override func initSubView() {
//        view.addSubview(collectionView)
    }
    
    override func layoutSubView() {
//        collectionView.snp.makeConstraints { $0.edges.equalTo(self.view) }
    }
    
}

extension CateVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fatalError()
    }
    
    
    
}
