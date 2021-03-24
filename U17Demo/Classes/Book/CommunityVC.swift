//
//  BookVC.swift
//  U17Demo
//
//  Created by 610582 on 2021/1/30.
//

import UIKit
import SnapKit
import KakaJSON
import SwiftyJSON
import Alamofire

class CommunityVC: BaseVC {
    
    var dataArray = [TrendPostModel]()
    
    lazy var tableView: UITableView = {
        let tb = UITableView(frame: .zero, style: .plain)
        tb.backgroundColor = .groupTableViewBackground
        let nib = UINib(nibName: "TrendInfoCell", bundle: nil)
        tb.register(nib, forCellReuseIdentifier: "TrendInfoCell")
        tb.estimatedRowHeight = 300
        tb.delegate = self
        tb.dataSource = self
        return tb
    }()

    override func initSubView() {
        view.addSubview(tableView)
    }
    
    override func layoutSubView() {
        tableView.snp.makeConstraints {
            $0.edges.equalTo(UIEdgeInsets.zero)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
    }
    
    func loadData() {
        let url = "https://jp.forum.1kxun.mobi/api/forum/specialPosts"
        
        //let param: [String : Any] = ["sexType" : 1]
        AF.request(url, parameters: nil).responseJSON {
            [weak self] (resultData) in
            
            switch resultData.result {
            case .success(let json):
                print("主页请求成功:")
                let dataList = (json as? NSDictionary)?["data"] as? NSArray
                let listModel = modelArray(from: dataList!, TrendPostModel.self)
                
                self?.dataArray += listModel
                self?.tableView.reloadData()
                break
            case .failure(let error):
                print("主页请求失败:", error)
                break
            }
        }
    }
}

extension CommunityVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrendInfoCell", for: indexPath) as! TrendInfoCell
        cell.selectionStyle = .none
        cell.model = dataArray[indexPath.row]
        return cell
    }
}
