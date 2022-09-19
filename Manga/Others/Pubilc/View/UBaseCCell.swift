//
//  UBaseCollectionViewCell.swift
//  Manga
//
//  Created by Luke on 2021/2/4.
//

import UIKit
import Reusable

class UBaseCCell: UICollectionViewCell, Reusable {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initAddSubView()
        
        layoutSubView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initAddSubView() {
        
    }
    
    func layoutSubView()  {
        
    }
}

class UBaseTableViewCell: UITableViewCell, Reusable {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        initAddSubView()
        
        layoutSubView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initAddSubView() {
        
    }
    
    func layoutSubView()  {
        
    }
}
