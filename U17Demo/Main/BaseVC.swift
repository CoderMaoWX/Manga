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
        view.backgroundColor = UIColor.white
        
        edgesForExtendedLayout = .all
        extendedLayoutIncludesOpaqueBars = false
        
        if #available(iOS 11.0, *) {
            UIScrollView.appearance().contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        initSubView()
        layoutSubView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.window?.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configNavgationBar()
    }
    
    func configNavgationBar() {
        guard let nav = navigationController else { return }
        
        if nav.visibleViewController == self {
            nav.barStyle(.theme)
            nav.setNavigationBarHidden(false, animated: true)
            
            if nav.viewControllers.count > 1 {
                let image = UIImage(named: "nav_back_white")?.withRenderingMode(.alwaysOriginal)
                navigationItem.leftBarButtonItem = UIBarButtonItem(image: image,
                                                                   style: .plain,
                                                                   target: self,
                                                                   action: #selector(goBackAction))
            }
        }
    }
    
    
    func initSubView() {
        
    }
    
    func layoutSubView()  {
        
    }
    
    @objc func goBackAction() {
        let vcArray: [UIViewController]! = navigationController?.viewControllers
        if vcArray.count > 1, vcArray?.last == self {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
