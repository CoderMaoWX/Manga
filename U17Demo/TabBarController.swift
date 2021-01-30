//
//  TabBarController.swift
//  U17Demo
//
//  Created by 610582 on 2021/1/29.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewController()
    }
    
    func setupViewController() {
        setupChildVC(childVC: HomeVC(), title: "首页", imageName: "tab_home", selImageName: "tab_home_s")
        setupChildVC(childVC: CateVC(), title: "分类", imageName: "tab_class", selImageName: "tab_class_s")
        setupChildVC(childVC: BookVC(), title: "书架", imageName: "tab_book", selImageName: "tab_book_s")
        setupChildVC(childVC: MineVC(), title: "我的", imageName: "tab_mine", selImageName: "tab_mine_s")
    }
    
    func setupChildVC(childVC: UIViewController, title: String, imageName: String, selImageName: String) {
        
        childVC.tabBarItem.image = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal)
        childVC.tabBarItem.selectedImage = UIImage(named: selImageName)?.withRenderingMode(.alwaysOriginal)
        childVC.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -4)
        childVC.tabBarItem.title = title
        addChild( UINavigationController(rootViewController: childVC) )
    }
    

}
