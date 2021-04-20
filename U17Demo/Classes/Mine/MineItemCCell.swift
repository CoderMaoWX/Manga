//
//  MineItemCCell.swift
//  U17Demo
//
//  Created by 610582 on 2021/4/19.
//

import UIKit
import Kingfisher
import SnapKit

class MineItemCCell: UBaseCollectionViewCell {
    
    var model: MineItemModel? {
        didSet {
            guard let model = model else { return }
            
            titleLabel.text = model.title
            
            let imageName = model.image
            
            if imageName.hasPrefix("http") {
                imageView.kf.setImage(with: URL(string: model.image))
            } else {
                imageView.image = UIImage(named: imageName)
            }
        }
    }
    
    override func initSubView() {
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
    }
    
    override func layoutSubviews() {
        imageView.snp.makeConstraints {
            $0.top.equalTo(snp.top)
            $0.centerX.equalTo(snp.centerX)
            $0.size.equalTo(CGSize(width: 40, height: 40))
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(10)
            $0.centerX.equalTo(snp.centerX)
        }
    }
    
    lazy var imageView: UIImageView = {
        let img = UIImageView(frame: .zero)
        img.contentMode = .scaleAspectFit
        return img
    }()
    
    lazy var titleLabel: UILabel = {
        let lab = UILabel(frame: .zero)
        lab.backgroundColor = .clear
        lab.textAlignment = .center
        lab.font = .systemFont(ofSize: 14)
        lab.textColor = .black
        lab.preferredMaxLayoutWidth = 70
        return lab
    }()
    
}
