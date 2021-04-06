//
//  TrendInfoCell.swift
//  U17Demo
//
//  Created by 610582 on 2021/3/24.
//

import UIKit
import Kingfisher
import SnapKitExtend

class TrendInfoCell: UITableViewCell {

    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var leveLabel: UILabel!
    @IBOutlet weak var trendTitleLabel: UILabel!
    @IBOutlet weak var trendDescLabel: UILabel!
    @IBOutlet weak var linkBtn1: UIButton!
    @IBOutlet weak var linkBtn2: UIButton!
    @IBOutlet weak var linkBtn3: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    
    @IBOutlet weak var ImgBgView: UIView!
    ///tag: 1, 2, 3
    @IBOutlet weak var imgView1: UIImageView!
    @IBOutlet weak var imgView2: UIImageView!
    @IBOutlet weak var imgView3: UIImageView!
    
    var model: TrendPostModel? {
        didSet {
            guard let model = model else { return }
            ImgBgView.isHidden = (model.images.count == 0)
            
            let imgArr = [imgView1, imgView2, imgView3]
            let _ = imgArr.map { $0?.isHidden = true }

            var index = 0
            for tmp in model.images {
                index += 1
                let tmpImg = ImgBgView.viewWithTag(index) as? UIImageView
                tmpImg?.isHidden = false
                let url = tmp.url
                tmpImg?.kf.setImage(with: URL(string: url))
            }

            //  axisType:方向
            //  fixedSpacing:中间间距
            //  leadSpacing:左边距(上边距)
            //  tailSpacing:右边距(下边距)
            imgArr.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 10, leadSpacing: 0, tailSpacing: 0)
            //  上面的可以约束x+w,还需要另外约束y+h
            //  约束y和height()如果方向是纵向,那么则另外需要设置x+w
            imgArr.snp.makeConstraints{
                $0.top.equalTo(0)
                $0.height.equalTo(ImgBgView)
            }
            
            let imgH = (model.images.count == 0) ? 0 : 126
            ImgBgView.snp.updateConstraints {
                $0.height.equalTo(imgH)
            }
            
            userImgView.kf.setImage(with: URL(string: model.icon))
            nameLabel.text = model.nickname
            leveLabel.text = model.level
            trendTitleLabel.text = model.title
            trendDescLabel.text = model.intro
            
            let linkBtnArr = [linkBtn1, linkBtn2, linkBtn3]
            let _ = linkBtnArr.map {  $0?.isHidden = true }
            
            var num = 100
            for tmp in model.specials {
                num += 1
                let tmpBtn = contentView.viewWithTag(num) as? UIButton
                tmpBtn?.isHidden = false
                let name = tmp.name
                tmpBtn?.setTitle(name, for: .normal)
//                tmpBtn?.setImage(UIImage(named: "write_post_insert_tag_button"), for: .normal)
            }
            
            timeLabel.text = model.bottomStr
            print("时间:", model.bottomStr)
            
            likeBtn.setTitle("", for: .normal)
            likeBtn.setImage(UIImage(named: ""), for: .normal)
            
            commentBtn.setTitle("", for: .normal)
            commentBtn.setImage(UIImage(named: ""), for: .normal)
        }
    }
    
}
