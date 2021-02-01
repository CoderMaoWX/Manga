//
//  NavigationVC.swift
//  U17Demo
//
//  Created by 610582 on 2021/2/1.
//

import UIKit

class NavigationVC: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.isTranslucent = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}
