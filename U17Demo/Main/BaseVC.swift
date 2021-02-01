//
//  BaseVC.swift
//  U17Demo
//
//  Created by 610582 on 2021/2/1.
//

import UIKit

class BaseVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        initSubView()
        
        layoutSubView()
    }
    
    func initSubView() {
        
    }
    
    func layoutSubView()  {
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
