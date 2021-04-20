//
//  BookVC.swift
//  Manga
//
//  Created by 610582 on 2021/1/30.
//

import UIKit
import SnapKit
import KakaJSON
import SwiftyJSON
import Alamofire

class CommunityVC: BaseVC {
    
    var dataArray = [TrendInfoModel]()
    
    lazy var tableView: UITableView = {
        let tb = UITableView(frame: .zero, style: .plain)
        tb.backgroundColor = UIColor(r: 247, g: 248, b: 248)
        tb.separatorStyle = .none
        let trend = UINib(nibName: "TrendInfoCell", bundle: nil)
        tb.register(trend, forCellReuseIdentifier: "TrendInfoCell")
        
        let recommed = UINib(nibName: "TrendRecommedCell", bundle: nil)
        tb.register(recommed, forCellReuseIdentifier: "TrendRecommedCell")
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
        
        //let param: [String : Any] = ["sexType" : 1]
        AF.request(url, parameters: dict).responseJSON {
            [weak self] (resultData) in
            
            switch resultData.result {
            case .success(let json):
                print("主页请求成功:", json)
//                let dataList = (json as? NSDictionary)?["data"] as? NSArray
//                let listModel = modelArray(from: dataList!, TrendPostModel.self)
                
                let trendModel = (json as? NSDictionary)?.kj.model(TrendModel.self)
                let listModel = trendModel?.data
                self?.dataArray += listModel ?? []
                self?.tableView.reloadData()
                break
                
            case .failure(let error):
                print("主页请求失败:", error)
                break
            }
        }
    }
    
    func pushWebVC(url: String?, title: String?) {
        guard let url = url else { return }
        let webVC = WebVC(url: url)
        webVC.title = title
        navigationController?.pushViewController(webVC, animated: true)
    }
}

extension CommunityVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model: TrendInfoModel = dataArray[indexPath.row]
        if model.type == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TrendInfoCell", for: indexPath) as! TrendInfoCell
            cell.model = model.post
            cell.linkBtnClosure = { [weak self] (link)  in
                let title = self?.dataArray[indexPath.row].post.title
                self!.pushWebVC(url: link, title: title)
            };
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TrendRecommedCell", for: indexPath) as! TrendRecommedCell
            cell.model = model
            cell.linkBtnClosure = { [weak self] (link)  in
                let title = self?.dataArray[indexPath.row].post.title
                self!.pushWebVC(url: link, title: title)
            };
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let link = dataArray[indexPath.row].post.click_url
        let title = dataArray[indexPath.row].post.title
        pushWebVC(url: link, title: title)
    }
}
