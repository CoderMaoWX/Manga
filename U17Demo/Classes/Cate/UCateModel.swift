//
//  UCateModel.swift
//  U17Demo
//
//  Created by 610582 on 2021/2/4.
//

import Foundation
import KakaJSON

struct RankingModel: Convertible {
    var argCon: Int = 0
    var argName: String?
    var argValue: Int = 0
    var canEdit: Bool = false
    var cover: String?
    var isLike: Bool = false
    var sortId: Int = 0
    var sortName: String?
    var title: String?
    var subTitle: String?
    var rankingType: Int = 0
}

struct TabModel: Convertible {
    var argName: String?
    var argValue: Int = 0
    var argCon: Int = 0
    var tabTitle: String?
}

struct TopExtra: Convertible {
    var title: String?
    var tabList: [TabModel]?
}

struct TopModel: Convertible {
    var sortId: Int = 0
    var sortName: String?
    var cover: String?
    var extra: TopExtra?
    var uiWeight: Int = 0
}

struct CateListModel: Convertible {
    var recommendSearch: String?
    var rankingList:[RankingModel]?
    var topList:[TopModel]?
}
