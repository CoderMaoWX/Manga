//
//  Global.swift
//  Manga
//
//  Created by Luke on 2021/2/19.
//

import UIKit
import Foundation
import Kingfisher

//============================ 给指定的类添加前缀来扩展方法 ============================

struct Manga<Base> {
    var base: Base
    init(_ base: Base) {
        self.base = base
    }
}

protocol MgCompatible {}
extension MgCompatible {
    var mg: Manga<Self> {
        get { Manga(self) }
        set {}
    }
    static var mg: Manga<Self>.Type {
        get { Manga.self }
        set {}
    }
}

//============================ 示例用法 ============================
/*
 extension String: MgCompatible {}
 
 extension Manga where Base == String {
     static func statusMethod() {
         print("测试静态方法")
     }
     func instanceMethod() {
         print("测试实例方法")
     }
     mutating func mutatingMethod() {
        print("测试结构体,枚举修改实例内存的方法")
    }
 }
 
 func mangaTest() {
     "Manga".mg.instanceMethod()
     String.mg.statusMethod()
 }
 */


//MARK: =========== UIImageView扩展加载图片 ===========

/**
 * 给UIImageView扩展加载图片的前缀,方便在日后一键全部替换底层图片加载框架
 */
extension UIImageView: MgCompatible {}
extension Manga where Base: UIImageView {
    func setImageURL(_ with: String?) {
        let url = URL(string: with ?? "")
        base.kf.setImage(with: url)
    }
    
    func setImageURL(with: String?, placeholder: String = "") {
        let url = URL(string: with ?? "")
        base.kf.setImage(with: url, placeholder: UIImage(named: placeholder))
    }
}


//extension UIView: MgCompatible {}
//extension Manga where Base: UIView {
//
////    base.snp.makeConstraints {
////        $0.edges.equalTo(view)
////    }
//
//    func makeConstraints(_ closure: (_ make: ConstraintMaker) -> Void) {
//        base.snp.makeConstraints(closure)
//    }
//}
