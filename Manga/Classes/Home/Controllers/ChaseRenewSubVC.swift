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
import Reusable

class ChaseRenewSubVC: BaseVC {
    
    var day: Int = 1
    
    private var dataArray = [CalenderListModel]()
    
    lazy var tableView: UITableView = {
        let tw = UITableView(frame: .zero)
        tw.delegate = self
        tw.dataSource = self
        tw.separatorStyle = .none
        tw.tableFooterView = UIView()
        tw.register(cellType: CalenderListCell.self)
        return tw
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        addRefreshHeader()
    }
    
    func addRefreshHeader() {
        tableView.addRefreshKit(startHeader: true, headerClosure: { [weak self] in
           self?.requestListData()
        })
    }
    
    override func initSubView() {
        view.addSubview(tableView)
    }
    
    override func layoutSubView() {
        tableView.snp.makeConstraints{
            $0.edges.equalTo(UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0))
        }
    }
    
    func requestListData() {
        var param: [String: Any] = [:]
        param["type"] = 1
        param["sex_tag"] = 1
        param["page"] = 0
        param["day"] = day
        param["sign"] = "269319caabbb10f593264ece026cd2d9"
        param["access_token"] = "144-0283f6da91d62eb6cbf59651e81a6bc5"
        param["_udid"] = "480023eb1c175fbc34aa1e130953e8a6"
        param["_token"] = "144-0283f6da91d62eb6cbf59651e81a6bc5"
        param["_package"] = "com.truecolor.Manga"
        param["_resolution"] = "1170,2532"
        param["_ov"] = "15.1.1"
        param["_model"] = "iPhone13,2"
        param["_mg_language"] = "zh_tw"
        param["_locale"] = "CN"
        param["_channel"] = "Appstore"
        param["_carrier"] = "中国电信"

        let api = WXRequestApi(path(.calender_list), method: .get, parameters: param)
        api.successStatusMap = (key: "status",  value: "success")
        api.parseModelMap = (parseKey: "data" , modelType: CalenderListModel.self)
        if tableView.mj_header?.state != .refreshing {
            api.loadingSuperView = view
        }
        api.startRequest { [weak self] (responseModel) in
            self?.dataArray = (responseModel.parseKeyPathModel as? [CalenderListModel]) ?? []
            self?.tableView.reloadData(autoEmptyViewInfo: self?.dataArray)
        }
    }
}


extension ChaseRenewSubVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: CalenderListCell.self)
        cell.model = dataArray[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        285
    }

}
