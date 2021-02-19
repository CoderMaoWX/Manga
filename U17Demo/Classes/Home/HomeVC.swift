//
//  HomeVC.swift
//  U17Demo
//
//  Created by 610582 on 2021/1/30.
//

import UIKit
import HMSegmentedControl
import Then

class HomeVC: BaseVC {

    lazy var segment: HMSegmentedControl = {
        return HMSegmentedControl().then {
            $0.addTarget(self, action: #selector(indexChange(segment:)), for: .valueChanged)
        }
    }()
    
    @objc func indexChange(segment: HMSegmentedControl) {
        
    }
    
    lazy var rightBtnView: UIBarButtonItem = {
        let rightBtn = UIBarButtonItem(image: UIImage(named: "nav_search"),style: .plain, target: self, action: #selector(clickBtn(buttonIetm:)))
        return rightBtn
    }()
    
    @objc func clickBtn(buttonIetm: UIBarButtonItem) {
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func initSubView() {
        navigationItem.titleView = segment
        navigationItem.rightBarButtonItem = rightBtnView
    }
    
    override func layoutSubView() {
        
    }
}
