//
//  Global.swift
//  U17Demo
//
//  Created by Luke on 2021/2/19.
//

import Foundation
import UIKit

extension UIColor {
    class var theme: UIColor {
        return UIColor(red: 0, green: 0, blue: 0, alpha: 1)
    }
    
    class var background: UIColor {
        return UIColor(red: 242, green: 242, blue: 242, alpha: 1)
    }
    
    class var arcColor: UIColor {
        return UIColor(red: CGFloat(arc4random_uniform(255))/255.0,
                       green: CGFloat(arc4random_uniform(255))/255.0,
                       blue: CGFloat(arc4random_uniform(255))/255.0,
                       alpha: 1)
    }
}
