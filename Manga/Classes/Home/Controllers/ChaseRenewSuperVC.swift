//
//  ChaseRenewSuperVC.swift
//  Manga
//
//  Created by 610582 on 2021/11/24.
//

import UIKit
import HMSegmentedControl

class ChaseRenewSuperVC: BaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func initSubView() {
        view.addSubview(pageVC.view)
        
        let colorKey = NSAttributedString.Key.foregroundColor
        let fontKey = NSAttributedString.Key.font
        segment.selectedSegmentIndex = UInt(currentSelectIndex)
        segment.backgroundColor = UIColor.clear
        segment.sectionTitles = titles as [String]?
        segment.selectionIndicatorLocation = .none
        segment.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 40)
        segment.titleTextAttributes = [colorKey : UIColor.gray,
                                        fontKey : UIFont.systemFont(ofSize: 14) ]
        
        segment.selectedTitleTextAttributes = [colorKey : UIColor.hex("#3BDD92"),
                                                fontKey : UIFont.boldSystemFont(ofSize: 14) ]
        view.addSubview(segment)
    }
    
    override func layoutSubView() {
        
    }
    
    var titles: [NSString] = ["周一", "周二", "周三", "周四", "周五", "周六", "周日"]
    let VCs: [UIViewController] = [
        ChaseRenewSubVC(), ChaseRenewSubVC(),ChaseRenewSubVC(),ChaseRenewSubVC(),
        ChaseRenewSubVC(), ChaseRenewSubVC(), ChaseRenewSubVC()
    ]
    var currentSelectIndex = 0

    lazy var segment: HMSegmentedControl = {
        let segmente = HMSegmentedControl()
        segmente.addTarget(self, action: #selector(indexChange(segment:)), for: .valueChanged)
        return segmente
    }()

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
}

extension ChaseRenewSuperVC : UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = VCs.firstIndex(of: viewController) else { return nil }
        let beforeIndex = index - 1
        guard beforeIndex >= 0 else { return nil }
        let tmpVC = VCs[beforeIndex]
        (tmpVC as! ChaseRenewSubVC).day = beforeIndex + 1
        return tmpVC
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = VCs.firstIndex(of: viewController) else { return nil }
        let afterIndex = index + 1
        guard afterIndex <= VCs.count - 1 else { return nil }
        let tmpVC = VCs[afterIndex]
        (tmpVC as! ChaseRenewSubVC).day = afterIndex + 1
        return tmpVC
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let viewController = pageViewController.viewControllers?.last, let index = VCs.firstIndex(of: viewController) else { return }
        currentSelectIndex = index
        segment.setSelectedSegmentIndex(UInt(index), animated: true)
    }

}
