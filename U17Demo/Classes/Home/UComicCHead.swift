//
//  UComicCHead.swift
//  U17Demo
//
//  Created by 610582 on 2021/2/20.
//

import UIKit
import SnapKit

class UComicCHead: UICollectionReusableView {
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubView()
        layoutSubView()
    }
    
    lazy var imgView: UIImageView = {
        let imgV = UIImageView(frame: CGRect.zero)
        imgV.contentMode = .scaleAspectFill
        return imgV
    }()
    
    lazy var titleLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 12)
        lb.textColor = UIColor.black
        return lb
    }()
    
    lazy var moreBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: ""), for: .normal)
        btn.addTarget(self, action: #selector(touchMoreBtn), for: .touchUpInside)
        return btn
    }()
    
    @objc func touchMoreBtn() {
        
    }
    
    func initSubView() {
        addSubview(imgView)
        addSubview(titleLabel)
        addSubview(moreBtn)
    }
    
    func layoutSubView()  {
        imgView.snp.makeConstraints {
            $0.leading.equalTo(self.snp.leading).offset(12)
            $0.centerY.equalTo(self.snp.centerY)
        }
        
        titleLabel.snp.makeConstraints{
            $0.leading.equalTo(imgView.snp.trailing).offset(12)
//            $0
        }
    }
}
