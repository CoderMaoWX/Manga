//
//  BookVC.swift
//  U17Demo
//
//  Created by 610582 on 2021/1/30.
//

import UIKit
import SnapKit

class CommunityVC: BaseVC {
    
    var dataArray = [TrendInfoModel]()
    
    lazy var tableView: UITableView = {
        let tb = UITableView(frame: .zero, style: .plain)
        tb.backgroundColor = .groupTableViewBackground
        let nib = UINib(nibName: NSStringFromClass(TrendInfoCell.self), bundle: Bundle(for: TrendInfoCell.self))
        tb.register(nib, forCellReuseIdentifier: NSStringFromClass(TrendInfoCell.self))
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
//        https://jp.forum.1kxun.mobi/api/forum/specialPosts?_=1616553270&_brand=Apple&_carrier=%E4%B8%AD%E5%9B%BD%E7%A7%BB%E5%8A%A8&_channel=Appstore&_idfa=1809AD50-995C-4F59-AB73-00DD0384D5A4&_locale=CN&_mg_language=zh_tw&_model=iPhone13%2C2&_ov=14.2&_package=com.truecolor.Manga&_resolution=1170%2C2532&_udid=948f9c4694912ff0e1c72e1b38581d80&_v=3.9.1&follow=0&id=1&page=0&sort_type=hot
    }
}

extension CommunityVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(TrendInfoCell.self), for: indexPath) as! TrendInfoCell
        cell.model = dataArray[indexPath.row].post
        return cell
    }
}
