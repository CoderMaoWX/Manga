//
//  PublicTools.swift
//  Manga
//
//  Created by 610582 on 2021/11/24.
//

import Foundation
import UIKit

///读取文件内容为字符串
func readFileToString(_ path: String) -> String? {
    let data = NSData(contentsOfFile: path)
    return data.flatMap {
        String(data: $0 as Data, encoding: .utf8)
    }
}
