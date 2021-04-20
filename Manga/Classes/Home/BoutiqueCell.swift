//
//  BoutiqueCell.swift
//  Manga
//
//  Created by 610582 on 2021/2/20.
//

import UIKit
import Kingfisher

class BoutiqueCell: UBaseCollectionViewCell {
    
    lazy var imageView: UIImageView = {
       let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    lazy var textLabel: UILabel = {
        let lb = UILabel()
        lb.backgroundColor = .white
        lb.font = .systemFont(ofSize: 14)
        lb.textColor = .black
        return lb
    }()
    
    lazy var subTextLabel: UILabel = {
        let lb = UILabel()
        lb.backgroundColor = .white
        lb.font = .systemFont(ofSize: 12)
        lb.textColor = .lightGray
        return lb
    }()
    
    override func initSubView() {
        clipsToBounds = true
        contentView.backgroundColor = .white
        contentView.addSubview(imageView)
        contentView.addSubview(textLabel)
        contentView.addSubview(subTextLabel)
    }
    
    override func layoutSubviews() {
        subTextLabel.snp.makeConstraints {
            $0.left.equalTo(contentView.snp.left).offset(10)
            $0.right.equalTo(contentView.snp.right).offset(-10)
            $0.bottom.equalTo(contentView.snp.bottom).offset(-5)
        }
        
        textLabel.snp.makeConstraints {
            $0.left.equalTo(subTextLabel.snp.left)
            $0.bottom.equalTo(subTextLabel.snp.top).offset(-10)
            $0.right.equalTo(subTextLabel.snp.right)
        }
        
        imageView.snp.makeConstraints {
            $0.left.right.top.equalTo(contentView)
            $0.bottom.equalTo(textLabel.snp.top).offset(-5)
        }
    }
    
    var model: ComicModel? {
        didSet {
            guard let model = model else { return }
            let url = URL(string: model.cover ?? "")
            imageView.kf.setImage(with: url)
            textLabel.text = model.name ?? model.title
            subTextLabel.text = model.subTitle ?? "更新至\(model.content ?? "0")集"
        }
    }
    
}
