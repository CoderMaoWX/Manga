//
//  TrendRecommedCell.swift
//  U17Demo
//
//  Created by 610582 on 2021/4/16.
//

import UIKit
import Kingfisher

typealias UTrendRecommedClosure = (String?)->()

class TrendRecommedCell: UITableViewCell {
    
    @IBOutlet weak var itemBtn0: UIButton!
    @IBOutlet weak var itemBtn1: UIButton!
    @IBOutlet weak var itemBtn2: UIButton!
    @IBOutlet weak var itemBtn3: UIButton!
    @IBOutlet weak var moreItemBtn: UIButton!
    
    var linkBtnClosure: UTrendRecommedClosure?
    
    @IBAction func itemBtnAction(_ sender: UIButton) {
        guard let linkBtnClosure = linkBtnClosure else { return }
        let url = model?.cicle[sender.tag-100].click_url
        linkBtnClosure(url)
    }
    
    @IBAction func moreItemBtnAction(_ sender: UIButton) {
        guard let linkBtnClosure = linkBtnClosure else { return }
        linkBtnClosure(model?.more_link)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    var model: TrendInfoModel? {
        didSet {
            guard let model = model else { return }
            
            var index = 99
            for item in model.cicle {
                index += 1
                let itemBtn = viewWithTag(index)
                guard let tmpBtn: UIButton = itemBtn as? UIButton else { continue }
                tmpBtn.kf.setImage(with: URL(string: item.image_url), for: .normal)
                tmpBtn.setTitle(item.name, for: .normal)
                tmpBtn.imageView?.contentMode = .scaleAspectFit
                tmpBtn.imageView?.clipsToBounds = true
                tmpBtn.clipsToBounds = false
                
            }
        }
    }
    
}
