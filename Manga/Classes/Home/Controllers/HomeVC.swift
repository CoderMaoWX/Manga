//
//  HomeVC.swift
//  Manga
//
//  Created by 610582 on 2021/1/30.
//

import UIKit
import HMSegmentedControl

class HomeVC: BaseVC {
    override func viewDidLoad() {
        navigationItem.title = nil
        super.viewDidLoad()
        addNavRightActionBtn()
    }
    
    func addNavRightActionBtn() {
        let search = UIImage(named: "acg_comment")!
        let ranking = UIImage(named: "acg_comment")!
        let note = UIImage(named: "acg_comment")!
        setNavBarRightItem(info: [search, ranking, note]) { button in
            debugLog(button)
        }
    }
    
    var titles: [NSString] = ["追更", "精选", "小说", "完本"]
    let VCs: [UIViewController] = [ChaseRenewSuperVC(), HandpickVC(), HandpickVC(), HandpickVC()]
    var currentSelectIndex = 0
    
    lazy var pageVC: UIPageViewController = {
        let pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageVC.delegate = self
        pageVC.dataSource = self
        pageVC.setViewControllers([VCs[0]], direction: .forward, animated: true, completion: nil)
        addChild(pageVC)
        return pageVC
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

    lazy var segment: HMSegmentedControl = {
        let segmente = HMSegmentedControl()
        segmente.addTarget(self, action: #selector(indexChange(segment:)), for: .valueChanged)
        return segmente
    }()
    
    override func initAddSubView() {
        view.addSubview(pageVC.view)
        
        let colorKey = NSAttributedString.Key.foregroundColor
        let fontKey = NSAttributedString.Key.font
        segment.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
        segment.backgroundColor = UIColor.clear
        segment.sectionTitles = titles as [String]?
        segment.selectionIndicatorLocation = .none
        segment.selectedSegmentIndex = UInt(currentSelectIndex)
        segment.titleTextAttributes = [colorKey : UIColor.white,
                                        fontKey : UIFont.systemFont(ofSize: 14) ]
        
        segment.selectedTitleTextAttributes = [colorKey : UIColor.white,
                                               fontKey  : UIFont.boldSystemFont(ofSize: 18) ]
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: segment)
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
        guard let viewController = pageViewController.viewControllers?.last, let index = VCs.firstIndex(of: viewController) else { return }
        currentSelectIndex = index
        segment.setSelectedSegmentIndex(UInt(index), animated: true)
    }

}
