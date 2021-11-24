//
//  CalenderListModel.swift
//  Manga
//
//  Created by Luke on 2021/11/24.
//

import Foundation
import KakaJSON

struct SubscriptModel : Convertible {
    var color: String?
    var words: String?
}

struct CalenderListModel : Convertible {
    var status: String?
    var id: Int = 0
    var image_url: String?
    var title: String?
    var horizontal_image_url: String?
    var tag: [String]?
    var episodes_count: Int = 0
    var episodes_title: String?
    var episodes_id: Int = 0
    var activity: [String]?
    var `subscript`: SubscriptModel?
    
}
