//
//  UBaseCollectionViewCell.swift
//  Manga
//
//  Created by Luke on 2021/2/4.
//

import UIKit
import Reusable

class UBaseCollectionViewCell: UICollectionViewCell, Reusable {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubView()
        
        layoutSubView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubView() {
        
    }
    
    func layoutSubView()  {
        
    }
}

class UBaseTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        initSubView()
        
        layoutSubView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubView() {
        
    }
    
    func layoutSubView()  {
        
    }
}
