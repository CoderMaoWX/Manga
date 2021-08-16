//
//  AlertController+Extension.swift
//  Manga
//
//  Created by 610582 on 2021/8/16.
//

import Foundation
import UIKit

///系统UIAlertController弹框 (最多两个个按钮)
@discardableResult
func showAlertController(title: String?, message: String?,
                         otherTitle: String? = nil,
                         otherClosure: (() -> ())? = nil,
                         cancelTitle: String,
                         cancelClosure: @escaping (() -> ())
                         ) -> UIAlertController {
    
    return showAlertMultiple(title: title,
                             message: message,
                             otherBtnTitles: (otherTitle != nil) ? [otherTitle!] : [],
                             otherBtnClosure: (otherClosure != nil) ? { _, _ in
                                otherClosure!()
                             } : nil,
                             cancelTitle: cancelTitle,
                             cancelClosure: cancelClosure)
}

///系统弹框 (可显示多个按钮)
@discardableResult
func showAlertMultiple(title: String?, message: String?,
                       otherBtnTitles: [String]? = nil,
                       otherBtnClosure: ((_ btnIndex: Int, _ btnTitle: String) -> ())? = nil,
                       cancelTitle: String,
                       cancelClosure: @escaping (() -> ()) ) -> UIAlertController {

    let alertController = UIAlertController(title: title, message: message)
    let colorKey = "_titleTextColor"
    
    //1.other Button
    if let otherTitles = otherBtnTitles {
        for idx in 0..<otherTitles.count {
            let btnTitle = otherTitles[idx]
            let otherAction = UIAlertAction(title: btnTitle, style: .default) {_ in
                if let closure = otherBtnClosure {
                    closure(idx, btnTitle)
                }
            }
            let array = namesOfMemberVaribale(cls: UIAlertAction.self)
            if array.contains(colorKey) {
                otherAction.setValue(UIColor.black, forKey: colorKey)
            }
            alertController.addAction(otherAction)
        }
    }

    ///2.cancel Button
    let cancelAction = UIAlertAction(title: cancelTitle, style: .default) {_ in
        cancelClosure()
    }
    let array = namesOfMemberVaribale(cls: UIAlertAction.self)
    if array.contains(colorKey) {
        cancelAction.setValue(UIColor.black, forKey: colorKey)
    }
    alertController.addAction(cancelAction)
    let window = UIApplication.shared.delegate?.window
    window??.rootViewController?.present(alertController, animated: true, completion: nil)
    return alertController
}


extension UIAlertController {
    
    public func enableDismissAtOutside() {
        let subviews = UIApplication.shared.keyWindow?.subviews
        
        guard let _subviews = subviews, _subviews.count > 0 else {
            return
        }
        let backgroundView = _subviews.last!
        backgroundView.isUserInteractionEnabled = true
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(backgroundViewAction(gr:)))
        backgroundView.addGestureRecognizer(tapGR)
    }
    
    @objc func backgroundViewAction(gr : UITapGestureRecognizer){
        dismiss(animated: true, completion: nil)
    }
}

