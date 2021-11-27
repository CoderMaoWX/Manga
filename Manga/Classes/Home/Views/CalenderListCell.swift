//
//  CalenderListCell.swift
//  Manga
//
//  Created by Luke on 2021/11/24.
//

import UIKit
import Reusable

class CalenderListCell: UITableViewCell, Reusable, NibLoadable {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var tagBtn: UIButton!
    
    @IBAction func showAllAction(_ sender: UIButton) {
        
    }
    
    var model: CalenderListModel? {
        didSet {
            guard let model = model else { return }
            imgView.mg.setImageURL(model.horizontal_image_url)
            titleLabel.text = model.title
            subTitleLabel.text = model.episodes_title
            tagBtn.setTitle(model.tag?.first, for: .normal)
        }
    }
    
}
