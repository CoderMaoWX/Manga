//
//  NavgationBarView.swift
//  Manga
//
//  Created by 610582 on 2021/8/31.
//

import UIKit
import SnapKit

class NavgationBarView: UIView {
    
    ///导航标题
    var title: String = "" {
        willSet {
            titleLabel.text = newValue
        }
    }
    
    ///是否显示底部线条
    var showBottomLine = true {
        didSet {
            bottomLine.isHidden = !showBottomLine
        }
    }

    required init(_ backAction: (()->())?) {
        super.init(frame: .zero)
        goBackButtonClosure = backAction
        initSubView()
        layoutSubView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - 布局UI
    
    ///由子类重写覆盖
    fileprivate func initSubView() {
        backgroundColor = .white
        addSubview(contentView)
        if goBackButtonClosure != nil {
            contentView.addSubview(backButton)
        }
        contentView.addSubview(titleLabel)
        contentView.addSubview(bottomLine)
    }
    
    ///由子类重写覆盖
    fileprivate func layoutSubView()  {
        contentView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(self)
            $0.height.equalTo(44)
        }
        
        if goBackButtonClosure != nil {
            backButton.snp.makeConstraints {
                $0.leading.bottom.equalTo(contentView)
                $0.size.equalTo(CGSize(width: 44, height: 44))
            }
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalTo(contentView.snp.centerX)
            $0.centerY.equalTo(contentView.snp.centerY)
        }
        
        bottomLine.snp.makeConstraints {
            $0.leading.bottom.trailing.equalTo(contentView)
            $0.height.equalTo(0.5)
        }
    }
    
    //MARK: -添加导航按钮
    
    ///添加左侧导航按钮
    fileprivate var leftItemActionClosure: NavBarItemActionClosure? = nil
    fileprivate var leftButtonArray: [UIButton] = []
    @discardableResult
    func setNavBarLeftItem(info: [Any], actionClosure: @escaping NavBarItemActionClosure ) -> [UIButton] {
        for button in leftButtonArray {
            button.removeFromSuperview()
        }
        leftItemActionClosure = actionClosure
        leftButtonArray = createNavBarItems(object: info, itemType:1, actionClosure: actionClosure)
        
        var tmpBtn: UIView? = nil
        for button in leftButtonArray {
            button.snp.makeConstraints {
                $0.centerY.equalTo(contentView.snp.centerY)
                if tmpBtn == nil {
                    $0.leading.equalTo(contentView.snp.leading).offset(12)
                } else {
                    $0.leading.equalTo(tmpBtn!.snp.trailing).offset(12)
                }
            }
            tmpBtn = button
        }
        return leftButtonArray
    }
    
    /// 添加右侧导航按钮
    fileprivate var rightItemActionClosure: NavBarItemActionClosure? = nil
    fileprivate var rightButtonArray: [UIButton] = []
    @discardableResult
    func setNavBarRightItem(infoArr: [Any], actionClosure: @escaping NavBarItemActionClosure ) -> [UIButton] {
        for button in rightButtonArray {
            button.removeFromSuperview()
        }
        rightItemActionClosure = actionClosure
        rightButtonArray = createNavBarItems(object: infoArr, itemType:2, actionClosure: actionClosure)
        
        var tmpBtn: UIView? = nil
        for button in rightButtonArray.reversed() {
            button.snp.makeConstraints {
                $0.centerY.equalTo(contentView.snp.centerY)
                if tmpBtn == nil {
                    $0.trailing.equalTo(contentView.snp.trailing).offset(-12)
                } else {
                    $0.trailing.equalTo(tmpBtn!.snp.leading).offset(-12)
                }
            }
            tmpBtn = button
        }
        return rightButtonArray
    }
    
    ///添加导航按钮
    fileprivate func createNavBarItems(object: [Any],
                                       itemType: Int,
                                       actionClosure: @escaping NavBarItemActionClosure ) -> [UIButton] {
        var barButtonArr: [UIButton] = []
        var index = -1
        
        for info in object {
            let button = UIButton(type: .system)
            if info is UIImage {
                var image = info as! UIImage
                image = image.withRenderingMode(.alwaysOriginal)
                button.setImage(image, for: .normal)
                
            } else if info is String {
                button.setTitle((info as! String), for: .normal)
                button.titleLabel?.font = .systemFont(ofSize: 14)
                
            }  else if info is NSAttributedString {
                button.titleLabel?.font = .systemFont(ofSize: 14)
                button.setAttributedTitle((info as! NSAttributedString), for: .normal)            } else {
                continue
            }
            button.sizeToFit()
            button.setTitleColor(UIColor.black, for: .normal)
            let width = max(30, button.bounds.size.width)
            let height = max(30, button.bounds.size.height)
            button.frame = CGRect(x: 0, y: 0, width: width , height: height)
            button.snp.makeConstraints {
                $0.size.equalTo(CGSize(width: width, height: height))
            }
            //let leftSpace: CGFloat = (itemType == 1) ? -8 : 0 //设置偏移
            //let rightSpace: CGFloat = (itemType == 1) ? 0 : -15
            //button.contentEdgeInsets = UIEdgeInsets(top: 0, left: leftSpace, bottom: 0, right: rightSpace)
            index += 1
            button.tag = index
            
            let selector = (itemType == 1) ? #selector(self.navBarLeftItemAction) : #selector(self.navBarRightItemAction)
            button.addTarget(self, action: selector, for: .touchUpInside)
            contentView.addSubview(button)
            barButtonArr.append(button)
        }
        return barButtonArr
    }
    
    ///左侧按钮事件
    @objc fileprivate func navBarLeftItemAction(sender: UIButton) {
        if let leftItemActionClosure = leftItemActionClosure {
            leftItemActionClosure(sender.tag)
        }
    }
    ///右侧按钮事件
    @objc fileprivate func navBarRightItemAction(sender: UIButton) {
        if let rightItemActionClosure = rightItemActionClosure {
            rightItemActionClosure(sender.tag)
        }
    }
    
    ///返回按钮事件
    fileprivate var goBackButtonClosure: ( ()->() )? = nil
    
    @objc fileprivate func goBackAction() {
        if let goBackButtonClosure = goBackButtonClosure {
            goBackButtonClosure()
        }
    }
    
    //MARK: - 懒加载UI
    
    fileprivate lazy var contentView: UIView = {
        let bgView = UIView()
        bgView.backgroundColor = .clear
        return bgView
    }()

    fileprivate lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.setImage(UIImage(named: "nav_back_white"), for: .normal)
        button.addTarget(self, action: #selector(goBackAction), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 18)
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    fileprivate lazy var bottomLine: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = .gray.withAlphaComponent(0.5)
        return lineView
    }()
    
}
