//
//  TabBarController.swift
//  Manga
//
//  Created by 610582 on 2021/1/29.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.isTranslucent = false
        tabBar.tintColor = UIColor.black //.theme
        setupViewController()

		fixTabbarBgColor()
    }

	func fixTabbarBgColor() {
		if #available(iOS 13.0, *) {
			let barApp = UITabBarAppearance()
			barApp.backgroundColor = .white
			barApp.backgroundImage = nil
			tabBar.standardAppearance = barApp
			if #available(iOS 15.0, *) {
				tabBar.scrollEdgeAppearance = barApp
			}
		}
	}
    
    func setupViewController() {
        let isTest = true //测试Api
        if isTest {
            setupChildVC(childVC: TestViewController(),
                         title: "测试",
                         imageName: "tabbar_item_default_0",
                         selImageName: "tabbar_item_default_0")
        }
        
        setupChildVC(childVC: HomeVC(),
                     title: "精选",
                     imageName: "tabbar_item_default_0",
                     selImageName: "tabbar_item_selected_0")

        setupChildVC(childVC: CateVC(),
                     title: "分类",
                     imageName: "tabbar_item_default_1",
                     selImageName: "tabbar_item_selected_1")
        
        setupChildVC(childVC: CommunityVC(),
                     title: "频道",
                     imageName: "tabbar_item_default_2",
                     selImageName: "tabbar_item_selected_2")
        
        setupChildVC(childVC: MineVC(),
                     title: "我的",
                     imageName: "tabbar_item_default_3",
                     selImageName: "tabbar_item_selected_3")
    }
    
    func setupChildVC(childVC: UIViewController, title: String, imageName: String, selImageName: String) {
        childVC.navigationItem.title = title
        childVC.tabBarItem.title = title
        childVC.tabBarItem.image = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal)
        childVC.tabBarItem.selectedImage = UIImage(named: selImageName)?.withRenderingMode(.alwaysOriginal)
        childVC.tabBarItem.imageInsets.top = 10
        addChild( BaseNavigationVC(rootViewController: childVC) )
    }

}
