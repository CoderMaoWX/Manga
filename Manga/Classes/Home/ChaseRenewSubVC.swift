//
//  ChaseRenewSubVC.swift
//  Manga
//
//  Created by 610582 on 2021/11/24.
//

import UIKit
import SnapKit
import MJRefresh
import WXNetworkingSwift
import KakaJSON

class ChaseRenewSubVC: BaseVC {
    
    var argCon: Int = 0
    var argName: String = ""
    var argValue: Int = 0
    let page: Int = 1
    
    private var dataArray = [ComicModel]()
    
    lazy var tableView: UITableView = {
        let tw = UITableView(frame: .zero)
//        tw.delegate = self
//        tw.dataSource = self
        tw.tableFooterView = UIView()
        tw.register(UDetailCateCell.self, forCellReuseIdentifier: NSStringFromClass(UDetailCateCell.self))
        return tw
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        loadListData()
    }
    
    override func initSubView() {
//        view .addSubview(tableView)
    }
    
    override func layoutSubView() {
//        tableView.snp.makeConstraints{ $0.edges.equalTo(view) }
    }
    
    func loadListData() {
        var param: [String: Any] = [:]
        param["type"] = 1
        param["sex_tag"] = 1
        param["sign"] = "269319caabbb10f593264ece026cd2d9"
        param["page"] = 0
        param["day"] = 1
        param["access_token"] = "144-0283f6da91d62eb6cbf59651e81a6bc5"
        param["_udid"] = "480023eb1c175fbc34aa1e130953e8a6"
        param["_token"] = "144-0283f6da91d62eb6cbf59651e81a6bc5"
        param["_resolution"] = "1170,2532"
        param["_package"] = "com.truecolor.Manga"
        param["_ov"] = "15.1.1"
        param["_model"] = "iPhone13,2"
        param["_mg_language"] = "zh_tw"
        param["_locale"] = "CN"
        param["_channel"] = "Appstore"
        param["_carrier"] = "中国电信"
//        param["_brand"] = "Apple"
//        param["_"] = "1637742865"

        let url = "https://manga.1kxun.mobi/api/calender/list"
        let request = WXRequestApi(url, method: .get, parameters: param)
        request.loadingSuperView = view
        request.successStatusMap = (key: "status",  value: "success")
        request.parseModelMap = (parseKey: "data.returnData.comics" , modelType: ComicModel.self)

        request.startRequest { [weak self] (responseModel) in
//            self?.dataArray = (responseModel.parseKeyPathModel as? [ComicModel]) ?? []
//            self?.tableView.reloadData(autoEmptyViewInfo: self?.dataArray)
        }
    }
}


//extension ChaseRenewSubVC: UITableViewDelegate, UITableViewDataSource {
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        dataArray.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell: UDetailCateCell = tableView .dequeueReusableCell(withIdentifier: NSStringFromClass(UDetailCateCell.self), for: indexPath) as! UDetailCateCell
//        cell.model = dataArray[indexPath.row]
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        180
//    }
//
//}
