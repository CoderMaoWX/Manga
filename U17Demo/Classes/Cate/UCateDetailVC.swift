//
//  UCateDetailVC.swift
//  U17Demo
//
//  Created by 610582 on 2021/2/7.
//

import UIKit
import SnapKit
import MJRefresh
import Alamofire
import KakaJSON

class UCateDetailVC: BaseVC {
    
    var argCon: Int = 0
    var argName: String = ""
    var argValue: Int = 0
    let page: Int = 1
    
    private var dataArray = [ComicModel]()
    
    lazy var tableView: UITableView = {
        let tw = UITableView(frame: .zero)
        tw.delegate = self
        tw.dataSource = self
        tw.tableFooterView = UIView()
        tw.register(UDetailCateCell.self, forCellReuseIdentifier: NSStringFromClass(UDetailCateCell.self))
        return tw
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        loadListData()
    }
    
    override func initSubView() {
        view .addSubview(tableView)
    }
    
    override func layoutSubView() {
        tableView.snp.makeConstraints{ $0.edges.equalTo(view) }
    }
    
    func loadListData() {
        let loadURL = "http://app.u17.com/v3/appV3_3/ios/phone/list/commonComicList"
        
        var param: [String: Any] = [:]
        param["argCon"] = argCon
        if argName.count > 0 { param["argName"] = argName }
        param["argValue"] = argValue
        
        AF.request(loadURL, method: .get, parameters: param).responseJSON {
            [weak self](returnData) in
            
            switch returnData.result {
            case .success(let json):
                let dataDict = ((json as? NSDictionary)?["data"] as? NSDictionary)?["returnData"]
                let listModel = model(from: (dataDict as! NSDictionary), ComicListModel.self)
                self?.dataArray = listModel?.comics ?? []
                self?.tableView.reloadData()
                break
                
            case .failure(let error):
                print("详情页面失败:", error)
                break
            }
        }
    }
}


extension UCateDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UDetailCateCell = tableView .dequeueReusableCell(withIdentifier: NSStringFromClass(UDetailCateCell.self), for: indexPath) as! UDetailCateCell
        cell.model = dataArray[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        180
    }
    
}
