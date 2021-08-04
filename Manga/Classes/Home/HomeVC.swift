//
//  HomeVC.swift
//  Manga
//
//  Created by 610582 on 2021/1/30.
//

import UIKit
import HMSegmentedControl

class HomeVC: BaseVC {
    
    var titles: [NSString] = ["推荐", "VIP", "订阅", "排行"]
    let VCs: [UIViewController] = [BoutiqueVC(), BoutiqueVC(), BoutiqueVC(), BoutiqueVC()]
    var currentSelectIndex = 0
    
    lazy var segment: HMSegmentedControl = {
        let segmente = HMSegmentedControl()
        segmente.addTarget(self, action: #selector(indexChange(segment:)), for: .valueChanged)
        return segmente
    }()
    
    lazy var pageVC: UIPageViewController = {
        return UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }()
     
    @objc func indexChange(segment: HMSegmentedControl) {
        let index = segment.selectedSegmentIndex
        if index == currentSelectIndex { return }
        
        let vcs: [UIViewController] = [ VCs[Int(index)] ]
        let direction: UIPageViewController.NavigationDirection = currentSelectIndex > Int(index) ? .reverse : .forward
        
        pageVC.setViewControllers(vcs, direction: direction, animated: true) { [weak self](bool) in
            self?.currentSelectIndex = Int(index)
        }
    }
    
    lazy var rightBtnView: UIBarButtonItem = {
        let image = UIImage(named: "nav_search")?.withRenderingMode(.alwaysOriginal)
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 44))
        btn.setImage(image, for: .normal)
        btn.addTarget(self, action: #selector(clickBtn(buttonIetm:)), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: btn);
        
        return UIBarButtonItem(customView: btn)
    }()
    
    @objc func clickBtn(buttonIetm: UIBarButtonItem) {
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func initSubView() {
        pageVC.delegate = self
        pageVC.dataSource = self
        pageVC.setViewControllers([VCs[0]], direction: .forward, animated: true, completion: nil)
        addChild(pageVC)
        view.addSubview(pageVC.view)
        
        segment.backgroundColor = UIColor.clear
        segment.sectionTitles = titles as [String]?
        segment.selectionIndicatorLocation = .none
        segment.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white.withAlphaComponent(0.5),
                                       NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20) ]
        
        segment.selectedTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white,
                                       NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 20) ]
        
        segment.selectedSegmentIndex = UInt(currentSelectIndex)
        segment.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width-120, height: 40)
        navigationItem.titleView = segment
        navigationItem.rightBarButtonItem = rightBtnView
    }
    
    override func layoutSubView() {
        
    }
}

extension HomeVC : UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = VCs.firstIndex(of: viewController) else { return nil }
        let beforeIndex = index - 1
        
        guard beforeIndex >= 0 else { return nil }
        return VCs[beforeIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = VCs.firstIndex(of: viewController) else { return nil }
        let afterIndex = index + 1
        guard afterIndex <= VCs.count - 1 else { return nil }
        return VCs[afterIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let viewController = pageViewController.viewControllers?.last,
            let index = VCs.firstIndex(of: viewController) else {
                return
        }
        currentSelectIndex = index
        segment.setSelectedSegmentIndex(UInt(index), animated: true)
    }
    
}
