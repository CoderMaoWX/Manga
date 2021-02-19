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
        tabBar.isTranslucent = false
    
        setupViewController()
    }
    
    func setupViewController() {
        setupChildVC(childVC: HomeVC(), title: "首页", imageName: "tab_home", selImageName: "tab_home_S")
        setupChildVC(childVC: CateVC(), title: "分类", imageName: "tab_class", selImageName: "tab_class_S")
        setupChildVC(childVC: BookVC(), title: "书架", imageName: "tab_book", selImageName: "tab_book_S")
        setupChildVC(childVC: MineVC(), title: "我的", imageName: "tab_mine", selImageName: "tab_mine_S")
    }
    
    func setupChildVC(childVC: UIViewController, title: String, imageName: String, selImageName: String) {
        //childVC.tabBarItem.title = title
        childVC.navigationItem.title = title
        childVC.tabBarItem.image = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal)
        childVC.tabBarItem.selectedImage = UIImage(named: selImageName)?.withRenderingMode(.alwaysOriginal)
        childVC.tabBarItem.imageInsets.top = 10
        addChild( NavigationVC(rootViewController: childVC) )
    }
    

}
