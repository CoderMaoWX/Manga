//
//  MineItemModel.swift
//  Manga
//
//  Created by 610582 on 2021/4/19.
//

import Foundation
import KakaJSON

struct MineItemModel: Convertible {
    let id: String = ""
    var title: String = ""
    var click_url: String?
    var image: String = ""
    let description: String = ""
    let update_time: String = ""
}

struct MineListModel: Convertible {
    var title: String = ""
    var list: [MineItemModel] = []
    
}
