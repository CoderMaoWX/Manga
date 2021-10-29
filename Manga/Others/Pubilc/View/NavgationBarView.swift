//
//  NavgationBarView.swift
//  Manga
//
//  Created by 610582 on 2021/8/31.
//

import UIKit
import SnapKit

let kButtonSpace = 12.0

class NavgationBarView: UIView {
    
    ///导航标题
    var title: String? {
        willSet {
            titleLabel.text = newValue
            titleLabel.isHidden = (newValue == nil)
        }
    }
    
    ///是否显示底部线条
    var showBottomLine = true {
        didSet {
            bottomLine.isHidden = !showBottomLine
        }
    }

    required init(backAction: (()->())?) {
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
        if goBackButtonClosure != nil {
            addSubview(backButton)
        }
        addSubview(titleLabel)
        addSubview(bottomLine)
    }
    
    ///由子类重写覆盖
    fileprivate func layoutSubView()  {
        if goBackButtonClosure != nil {
            backButton.snp.makeConstraints {
                $0.leading.bottom.equalTo(self)
                $0.size.equalTo(CGSize(width: 44.0, height: 44.0))
            }
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalTo(self.snp.centerX)
            $0.bottom.equalTo(self)
            $0.height.greaterThanOrEqualTo(44.0)
        }
        
        bottomLine.snp.makeConstraints {
            $0.leading.bottom.trailing.equalTo(self)
            $0.height.equalTo(0.5)
        }
    }
    
    //MARK: -添加导航按钮
    
    ///添加左侧导航按钮
    fileprivate var leftItemActionClosure: NavBarItemActionClosure? = nil
    fileprivate var leftButtonArray: [UIButton] = []
    @discardableResult
    func setLeftItem(info: [Any], actionClosure: @escaping NavBarItemActionClosure ) -> [UIButton] {
        for button in leftButtonArray {
            button.removeFromSuperview()
        }
        leftItemActionClosure = actionClosure
        leftButtonArray = createNavBarItems(object: info, itemType:1, actionClosure: actionClosure)
        
        var tmpBtn: UIView? = nil
        for button in leftButtonArray {
            addSubview(button)
            button.snp.makeConstraints {
                $0.centerY.equalTo(titleLabel.snp.centerY)
                if tmpBtn == nil {
                    $0.leading.equalTo(self.snp.leading).offset(kButtonSpace)
                } else {
                    $0.leading.equalTo(tmpBtn!.snp.trailing).offset(kButtonSpace)
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
    func setRightItem(infoArr: [Any], actionClosure: @escaping NavBarItemActionClosure ) -> [UIButton] {
        for button in rightButtonArray {
            button.removeFromSuperview()
        }
        rightItemActionClosure = actionClosure
        rightButtonArray = createNavBarItems(object: infoArr, itemType:2, actionClosure: actionClosure)
        
        var tmpBtn: UIView? = nil
        for button in rightButtonArray.reversed() {
            addSubview(button)
            button.snp.makeConstraints {
                $0.centerY.equalTo(titleLabel.snp.centerY)
                if tmpBtn == nil {
                    $0.trailing.equalTo(self.snp.trailing).offset(-kButtonSpace)
                } else {
                    $0.trailing.equalTo(tmpBtn!.snp.leading).offset(-kButtonSpace)
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
                button.setAttributedTitle((info as! NSAttributedString), for: .normal)
            } else {
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
            
            let selector = (itemType == 1) ? #selector(self.leftButtonItemAction) : #selector(self.rightButtonItemAction)
            button.addTarget(self, action: selector, for: .touchUpInside)
            barButtonArr.append(button)
        }
        return barButtonArr
    }
    
    ///左侧按钮事件
    @objc fileprivate func leftButtonItemAction(sender: UIButton) {
        if let leftItemActionClosure = leftItemActionClosure {
            leftItemActionClosure(sender)
        }
    }
    ///右侧按钮事件
    @objc fileprivate func rightButtonItemAction(sender: UIButton) {
        if let rightItemActionClosure = rightItemActionClosure {
            rightItemActionClosure(sender)
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

    fileprivate lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        let image = UIImage(named: "nav_back_black")?.colorImage(color: .black)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(goBackAction), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.backgroundColor = .clear
        label.font = .systemFont(ofSize: 18)
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        label.isHidden = true
        return label
    }()
    
    fileprivate lazy var bottomLine: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = .gray.withAlphaComponent(0.5)
        return lineView
    }()
    
}
