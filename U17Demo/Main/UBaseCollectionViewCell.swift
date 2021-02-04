//
//  UBaseCollectionViewCell.swift
//  U17Demo
//
//  Created by Luke on 2021/2/4.
//

import UIKit

class UBaseCollectionViewCell: UICollectionViewCell {
    
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
