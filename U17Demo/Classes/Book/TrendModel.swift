//
//  TrendModel.swift
//  U17Demo
//
//  Created by 610582 on 2021/3/24.
//

import Foundation

struct TrendInfoModel {
    var post : TrendPostModel
    var type : Int
}

struct TrendPostModel {
    var attributeImage : String
    var bottomStr : String
    var clickUrl : String
    var commentN : Int
    var commentImg : String
    var createdAt : Int
    var date : String
    var followUser : Int
    var icon : String
    var id : Int
    var ilikeImg : String
    var image : String
    var images : [TrendImage]
    var intro : String
    var isCartoonAuthor : Int
    var isRedStarShow : Bool
    var isVip : Bool
    var level : String
    var levelN : Int
    var likeN : Int
    var likeImg : String
    var liked : Bool
    var lotteryStatus : Int
    var medals : [String]
    var nickname : String
    var role : Int
    var specials : [TrendSpecial]
    var status : Int
    var title : String
    var userFlagIcon : String
    var userId : Int
    var vip : [AnyObject]
    var voteId : Int
}

struct TrendSpecial {
    var clickUrl : String
    var name : String
    var type : Int
}
struct TrendImage {
    var height : String
    var url : String
    var width : String
}
