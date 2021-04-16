//
//  TrendModel.swift
//  U17Demo
//
//  Created by 610582 on 2021/3/24.
//

import Foundation
import KakaJSON

struct TrendModel: Convertible  {
    var data : [TrendInfoModel] = []
    var timestamp : Int = 0
    var total_count : Int = 0
}


struct TrendInfoModel: Convertible  {
    var post : TrendPostModel = TrendPostModel()
    var type : Int = 0
    var cicle : [CicleModel] = []
    var more_link : String = ""
}

struct CicleModel: Convertible  {
    var name : String = ""
    var click_url : String = ""
    var image_url : String = ""
}

struct TrendPostModel: Convertible {
    var attributeImage : String = ""
    var bottomStr : String = ""
    var click_url : String = ""
    var commentN : String = ""
    var commentImg : String = ""
    var createdAt : Int = 0
    var date : String = ""
    var followUser : Int = 0
    var icon : String = ""
    var id : Int = 0
    var ilikeImg : String = ""
    var image : String = ""
    var images : [TrendImage] = []
    var intro : String = ""
    var isCartoonAuthor : Int = 0
    var isRedStarShow : Bool = false
    var is_vip : Bool = false
    var level : String = ""
    var levelN : String = ""
    var likeN : String = ""
    var likeImg : String = ""
    var liked : Bool = false
    var lotteryStatus : Int = 0
    var medals : [String] = []
    var nickname : String = ""
    var role : Int = 0
    var specials : [TrendSpecial] = []
    var status : Int = 0
    var title : String = ""
    var userFlagIcon : String = ""
    var userId : Int = 0
    var vip : [AnyObject] = []
    var voteId : Int = 0
    
    func kj_modelKey(from property: Property) -> ModelPropertyKey {
            // 由于开发中可能经常遇到`驼峰`映射`下划线`的需求，KakaJSON已经内置了处理方法
            // 直接调用字符串的underlineCased方法就可以从`驼峰`转为`下划线`
            // `nickName` -> `nick_name`
            return property.name.kj.underlineCased()
        }
}

struct TrendSpecial: Convertible {
    var clickUrl : String = ""
    var name : String = ""
    var type : Int = 0
    
    func kj_modelKey(from property: Property) -> ModelPropertyKey {
            // 由于开发中可能经常遇到`驼峰`映射`下划线`的需求，KakaJSON已经内置了处理方法
            // 直接调用字符串的underlineCased方法就可以从`驼峰`转为`下划线`
            // `nickName` -> `nick_name`
            return property.name.kj.underlineCased()
        }
}

struct TrendImage: Convertible {
    var height : String = ""
    var url : String = ""
    var width : String = ""
}
