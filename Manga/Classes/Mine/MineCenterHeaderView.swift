//
//  MineCenterHeaderView.swift
//  Manga
//
//  Created by 610582 on 2021/4/19.
//

import UIKit
import SnapKit

class MineCenterHeaderView: UICollectionReusableView {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = .white
    }
    
}

class MineCenterTextHeaderView: UICollectionReusableView {
    
//    var title: String?
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var title: String? {
        didSet {
            guard let title = title else { return }
            titleLabel.text = title
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        wx_initUI()
        wx_layoutUI()
    }
    
    func wx_initUI() {
        addSubview(lineView)
        addSubview(titleLabel)
    }
    
    func wx_layoutUI() {
        lineView.snp.makeConstraints{
            $0.leading.equalTo(snp.leading).offset(-5)
            $0.size.equalTo(CGSize(width: 10, height: 20))
            $0.centerY.equalTo(snp.centerY)
        }
        
        titleLabel.snp.makeConstraints{
            $0.leading.equalTo(lineView.snp.trailing).offset(12)
            $0.centerY.equalTo(snp.centerY)
        }
    }
    
    lazy var lineView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .theme
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let lab = UILabel(frame: .zero)
        lab.backgroundColor = .clear
        lab.textColor = .black
        lab.font = .systemFont(ofSize: 16)
        return lab
    }()
        
}
