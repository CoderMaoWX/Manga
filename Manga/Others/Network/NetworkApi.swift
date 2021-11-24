//
//  NetworkApi.swift
//  Manga
//
//  Created by Luke on 2021/11/24.
//

import Foundation

func Api(_ pathPort: PathPort) -> String {
    return "https://manga.1kxun.mobi/" + pathPort.rawValue
}

enum PathPort: String {
    case calenderList = "api/calender/list"
    case calenderList2 = "api/calender/list2"
}
