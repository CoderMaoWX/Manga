//
//  NetworkApi.swift
//  Manga
//
//  Created by Luke on 2021/11/24.
//

import Foundation

func path(_ pathPort: WXRequestPort) -> String {
    return "https://manga.1kxun.mobi/" + pathPort.rawValue
}

enum WXRequestPort: String {
    case calender_list = "api/calender/list"
    case calender_list2 = "api/calender/list2"
}
