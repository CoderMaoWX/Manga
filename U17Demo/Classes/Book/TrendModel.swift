//
//  TrendModel.swift
//  U17Demo
//
//  Created by 610582 on 2021/3/24.
//

import Foundation
import KakaJSON

struct TrendInfoModel: Convertible  {
    init() { self.init() }
    
    var post : TrendPostModel
    var type : Int = 0
}

struct TrendPostModel: Convertible {

    var attributeImage : String = ""
    var bottomStr : String = ""
    var clickUrl : String = ""
    var commentN : Int = 0
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
    var isVip : Bool = false
    var level : String = ""
    var levelN : Int = 0
    var likeN : Int = 0
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
}

struct TrendSpecial: Convertible {
    var clickUrl : String = ""
    var name : String = ""
    var type : Int = 0
}

struct TrendImage: Convertible {
    var height : String = ""
    var url : String = ""
    var width : String = ""
}
