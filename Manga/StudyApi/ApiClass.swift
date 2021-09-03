//
//  ApiClass.swift
//  WXSwiftDemo
//
//  Created by Luke on 2021/7/29.
//

import UIKit

class ApiClass: NSObject {
    
    
    @objc class func studyApi() {
        debugLog("Hello, World! StudyApi")

        let arr: [String] = ["1c", "2", "6q", "89", "2", "34"]

        let map = arr.map {
            Int($0)
        }
        // 1.map: 映射
        debugLog("map:", map)
        //map: [Optional(1), Optional(2), Optional(6), Optional(89), Optional(2), Optional(34)]


        // 2.compactMap: 映射
        let compactMap = arr.compactMap {
			Int($0)
        }
        debugLog("compactMap:", compactMap)
        //compactMap: [1, 2, 6, 89, 2, 34]


        // 3.flatMap: 关联操作
        let arr2 = [1, 2, 3]
        let flatMap = arr2.flatMap {
            Array.init(repeating: $0, count: $0)
        }
        debugLog("flatMap:", flatMap)
        //flatMap: [1, 2, 2, 3, 3, 3]


        // 4.filter: 过滤
        let filter = arr.filter {
            Int($0)! % 2 == 0
        }
        debugLog("filter:", filter)
        //filter: ["2", "6", "2", "34"]


        // 5.reduce: 关联操作
        let arr3 = [1, 2, 3, 4]
        let reduce = arr3.reduce([]) { $0 + [$1 * 2]}
        debugLog("reduce:", reduce)
        //reduce: [2, 4, 6, 8]


        ///可选项: map, flatMap
        let num: Int? = 20
        let num2 = num.map { Optional.some($0 * 2) }
        let num3 = num.flatMap { Optional.some($0 * 2) }
        debugLog("num:", num2!!, num3!)



        let fmt = DateFormatter()
        fmt.dateFormat = "YYYY-MM-DD"

        let str: String? = "2021-05-10"

        let date = str.map {
            fmt.date(from: $0)
        }
        debugLog("date:", date!!)

        let date2 = str.flatMap {
            fmt.date(from: $0)
        }
        debugLog("date2:", date2!)

        let date3 = str.flatMap(fmt.date)
        debugLog("date3:", date3!)


        let score: Int? = nil
        let score2 = score.map {
            "Score is \($0)"
        } ?? "bad Score"
        debugLog("score2", score2)


        let objArr = [11, 22, 22,33]
        let index = objArr.firstIndex(of: 33)
        debugLog("objArr", index!)

    }
}
