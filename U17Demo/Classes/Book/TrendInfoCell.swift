//
//  TrendInfoCell.swift
//  U17Demo
//
//  Created by 610582 on 2021/3/24.
//

import UIKit
import Kingfisher

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
    
    var model: TrendPostModel? {
        didSet {
            guard let model = model else { return }
            
            userImgView.kf.setImage(with: URL(string: model.icon))
            nameLabel.text = model.nickname
            leveLabel.text = "LV." + model.level
            trendTitleLabel.text = model.title
            trendDescLabel.text = model.intro
            
            linkBtn1.setTitle("", for: .normal)
            linkBtn1.setImage(UIImage(named: ""), for: .normal)
            
            linkBtn2.setTitle("", for: .normal)
            linkBtn2.setImage(UIImage(named: ""), for: .normal)
            
            linkBtn3.setTitle("", for: .normal)
            linkBtn3.setImage(UIImage(named: ""), for: .normal)
            
            timeLabel.text = model.bottomStr
            
            likeBtn.setTitle("", for: .normal)
            likeBtn.setImage(UIImage(named: ""), for: .normal)
            
            commentBtn.setTitle("", for: .normal)
            commentBtn.setImage(UIImage(named: ""), for: .normal)
        }
    }
    
}
