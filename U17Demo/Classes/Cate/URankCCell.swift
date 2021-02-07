//
//  URankCCell.swift
//  U17Demo
//
//  Created by Luke on 2021/2/4.
//

import UIKit
import Kingfisher
import SnapKit

class URankCCell: UBaseCollectionViewCell {
    
    lazy var imageView: UIImageView = {
       let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    lazy var textLabel: UILabel = {
        let lb = UILabel()
        lb.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        lb.font = UIFont.systemFont(ofSize: 14)
        lb.textAlignment = .center
        lb.textColor = .white
        return lb
    }()
    
    override func initSubView() {
        layer.cornerRadius = 5
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        
        contentView.addSubview(imageView)
        contentView.addSubview(textLabel)
    }
    
    override func layoutSubviews() {
        imageView.snp.makeConstraints {
            $0.edges.equalTo(contentView)
        }
        textLabel.snp.makeConstraints {
            $0.left.right.bottom.equalTo(contentView)
            $0.height.equalTo(25)
        }
    }
    
    var model: RankingModel? {
        didSet {
            guard let model = model else { return }
            
            let url = URL(string: model.cover!)
            imageView.kf.setImage(with: url)
            
            textLabel.text = model.sortName
        }
    }
}
