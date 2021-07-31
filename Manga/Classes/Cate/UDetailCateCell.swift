//
//  UDetailCateCell.swift
//  Manga
//
//  Created by 610582 on 2021/2/7.
//

import UIKit
import SnapKit

class UDetailCateCell: UBaseTableViewCell {
    
    lazy var imgView: UIImageView = {
        let iw = UIImageView()
        iw.contentMode = .scaleAspectFill
        iw.clipsToBounds = true
        return iw
    }()
    
    lazy var titleLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = UIColor.black
        lb.font = UIFont.systemFont(ofSize: 14)
        return lb
    }()
    
    lazy var subTitleLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = UIColor.gray
        lb.font = UIFont.systemFont(ofSize: 13)
        return lb
    }()
    
    lazy var descLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = UIColor.gray
        lb.font = UIFont.systemFont(ofSize: 13)
        lb.numberOfLines = 0
        return lb
    }()
    
    override func initSubView() {
        contentView .addSubview(imgView)
        contentView .addSubview(titleLabel)
        contentView .addSubview(subTitleLabel)
        contentView .addSubview(descLabel)
    }
    
    override func layoutSubviews() {
        imgView.snp.makeConstraints {
            $0.top.equalTo(contentView).offset(10)
            $0.leading.equalTo(contentView).offset(10)
            $0.width.equalTo(100)
            $0.bottom.equalTo(contentView.snp.bottom).offset(-10)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imgView.snp.top).offset(10)
            $0.leading.equalTo(imgView.snp.trailing).offset(10)
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(15)
            $0.leading.equalTo(titleLabel.snp.leading)
            $0.trailing.equalTo(contentView.snp.trailing).offset(-15)
        }
        
        descLabel.snp.makeConstraints {
            $0.top.equalTo(subTitleLabel.snp.bottom).offset(15)
            $0.leading.equalTo(subTitleLabel.snp.leading)
            $0.trailing.equalTo(contentView.snp.trailing).offset(-15)
            $0.bottom.equalTo(contentView.snp.bottom).offset(-15)
        }
    }
    
    
    var model: ComicModel? {
        
        didSet {
            guard let model = model else { return }
            
            imgView.mg.setImageURL(model.cover)
            
            titleLabel.text = model.name
            subTitleLabel.text = "\(model.tags?.joined(separator: " ") ?? "") | \(model.author ?? "")"
            descLabel.text = model.description
        }
    }
    
}
