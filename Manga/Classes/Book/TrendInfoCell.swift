//
//  TrendInfoCell.swift
//  Manga
//
//  Created by 610582 on 2021/3/24.
//

import UIKit
import SnapKitExtend

typealias UTrendInfoCellActionClosure = (String?)->()

class TrendInfoCell: UITableViewCell {
    
    ///tag: 50, 51, 51
    @IBOutlet weak var iconImg1: UIImageView!
    @IBOutlet weak var iconImg2: UIImageView!
    @IBOutlet weak var iconImg3: UIImageView!

    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var leveLabel: UILabel!
    @IBOutlet weak var trendTitleLabel: UILabel!
    @IBOutlet weak var trendDescLabel: UILabel!
    @IBOutlet weak var lotteryStatusBtn: UIButton!
    @IBOutlet weak var linkBtn1: UIButton!
    @IBOutlet weak var linkBtn2: UIButton!
    @IBOutlet weak var linkBtn3: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    
    @IBOutlet weak var ImgBgView: UIView!
    ///tag: 101, 102, 103
    @IBOutlet weak var imgView1: UIImageView!
    @IBOutlet weak var imgView2: UIImageView!
    @IBOutlet weak var imgView3: UIImageView!
    
    var linkBtnClosure: UTrendInfoCellActionClosure?
    
    
    @IBAction func linkBtnAction(_ sender: UIButton) {
        guard sender.tag > 100 else { return }
        
        guard let linkBtnClosure = linkBtnClosure else { return }
        if (model?.specials.count)! > (sender.tag - 101) {
            let linkStr = model?.specials[sender.tag - 101].clickUrl
            linkBtnClosure(linkStr);
        }
    }
    
    var model: TrendPostModel? {
        didSet {
            guard let model = model else { return }
            
            ///icon
            let iconArr = [iconImg1, iconImg2, iconImg3]
            let _ = iconArr.map { $0?.isHidden = true }
            var icon = 49
            for tmp in model.medals {
                icon += 1
                let imgView = viewWithTag(icon) as? UIImageView
                imgView?.isHidden = false
                imgView?.mg.setImageURL(tmp)
            }
            
            //图片
            ImgBgView.isHidden = (model.images.count == 0)
            
            let imgArr = [imgView1, imgView2, imgView3]
            let _ = imgArr.map { $0?.isHidden = true }
            var index = 0
            for tmp in model.images {
                index += 1
                let imgView = ImgBgView.viewWithTag(index) as? UIImageView
                imgView?.isHidden = false
                imgView?.mg.setImageURL(with: tmp.url, placeholder: "normal_placeholder_h")
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
            
            userImgView.mg.setImageURL(model.icon)
            nameLabel.text = model.nickname
            leveLabel.text = model.level
            trendTitleLabel.text = model.title
            trendDescLabel.text = model.intro
            
            let lottery = (model.lotteryStatus == 1) ? "进行中" : "已开奖"
            lotteryStatusBtn.setTitle(lottery, for: .normal)
            lotteryStatusBtn.backgroundColor = (model.lotteryStatus == 1) ? UIColor(r: 249, g: 84, b: 84) : UIColor(r: 192, g: 192, b: 192)
            
            let linkBtnArr = [linkBtn1, linkBtn2, linkBtn3]
            let _ = linkBtnArr.map {  $0?.isHidden = true }
            
            var num = 100
            for tmp in model.specials {
                num += 1
                let tmpBtn = contentView.viewWithTag(num) as? UIButton
                tmpBtn?.isHidden = false
                let name = tmp.name
                tmpBtn?.setTitle(name, for: .normal)
            }
            
            timeLabel.text = model.bottomStr
            
            likeBtn.setTitle("  "+model.likeN, for: .normal)
            likeBtn.setImage(UIImage(named: "acg_like"), for: .normal)
            
            commentBtn.setTitle("  "+model.commentN, for: .normal)
            commentBtn.setImage(UIImage(named: "acg_comment"), for: .normal)
        }
    }
    
}
