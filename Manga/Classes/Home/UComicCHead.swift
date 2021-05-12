//
//  UComicCHead.swift
//  Manga
//
//  Created by 610582 on 2021/2/20.
//

import UIKit
import Kingfisher
import SnapKit
import Reusable

typealias UComicCHeadMoreActionClosure = ()->Void

class UComicCFoot: UICollectionReusableView, Reusable {
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.background
    }
}

class UComicCHead: UICollectionReusableView, Reusable {
    
    private var moreActionClosure: UComicCHeadMoreActionClosure?
    
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
        imgV.clipsToBounds = true
        return imgV
    }()
    
    lazy var titleLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 14)
        lb.textColor = UIColor.black
        return lb
    }()
    
    lazy var moreBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("•••", for: .normal)
        btn.setTitleColor(UIColor.lightGray, for: .normal)
        btn.addTarget(self, action: #selector(touchMoreBtn), for: .touchUpInside)
        return btn
    }()
    
    @objc func touchMoreBtn() {
        guard let moreActionClosure = moreActionClosure else { return }
        moreActionClosure()
    }
    
    func touchMoreAction(_ closure: @escaping UComicCHeadMoreActionClosure) {
        moreActionClosure = closure
    }
    
    func initSubView() {
        clipsToBounds = true
        addSubview(imgView)
        addSubview(titleLabel)
        addSubview(moreBtn)
    }
    
    func layoutSubView()  {
        imgView.snp.makeConstraints {
            $0.leading.equalTo(self.snp.leading).offset(10)
            $0.centerY.equalTo(self.snp.centerY)
            $0.width.height.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints{
            $0.leading.equalTo(imgView.snp.trailing).offset(10)
            $0.centerY.equalTo(imgView.snp.centerY)
        }
        
        moreBtn.snp.makeConstraints{
            $0.centerY.equalTo(imgView.snp.centerY)
            $0.trailing.equalTo(self.snp.trailing).offset(-10)
        }
    }
    
    var model: ComicListModel? {
        didSet {
            guard let model = model else { return }
            
            let url = URL(string: model.newTitleIconUrl ?? "")
            
            imgView.kf.setImage(with: url)
            
            titleLabel.text = model.itemTitle
        }
    }
}
