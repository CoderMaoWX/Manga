//
//  ApiClass.swift
//  WXSwiftDemo
//
//  Created by Luke on 2021/7/29.
//

import UIKit

//class A_Class<T> {
//    var property: T? = nil
//    var b_class: B_Class<T>? = nil
//
//    func a_class_method<T>(property: T) {
//        let bClass = B_Class<T>()
//        b_class = bClass.b_class_method()
//    }
//}
//
//class B_Class<T> {
//    var c_class: C_Class<T>? = nil
//
//    func b_class_method() -> Self {
//        return self
//    }
//}
//
//class C_Class<T> {
//    var property: T? = nil
//
//}


let indices = [1, 2, 3]
let people = ["Eric", "Maeve", "Otis"]
let millennia = [1000, 2000, 3000]
let geese = ["Golden", "Mother", "Untitled"]

struct PaintMixer {
    enum ZFColor {
        case red, green, blue, tartan
    }
    
    func handle(color: ZFColor) {
        
    }
}

class StudentModel: Codable {
    var book = "你好啊,李银河"
    var name = "张三"
    var age = 28
    var address = "广东省深圳市宝安区"
    var menkey = 1000.0
    var cookie = "🍪"
    var nala: Float = 18
}

@propertyWrapper
struct Clamped<T: Comparable> {
    let wrappedValue: T

    init(wrappedValue: T, range: ClosedRange<T>) {
        self.wrappedValue = min(max(wrappedValue, range.lowerBound), range.upperBound)
    }
}


class ApiClass: NSObject {
    
    ///APi学习
    static func studyApi() {
        testApi()
    }
    
    static func testApi() {
        //        var dataArray = [1,2,3,4,5,6,7,8,9,0]
        //        dataArray.removeAll { $0 == 7 }
        //        debugLog("dataArray: \(dataArray)")
        //
        //        let word = "Backwards"
        //        let reversedWord = String(word.reversed())
        //        print(reversedWord)
        
        let expenses = [21.37, 55.21, 9.32, 10.18, 388.77, 11.41]
        
        let a = expenses.drop { item in
            item != 10.18
        }
        print("drop aaa22= : \(a)")
        
        let hasBigPurchase = expenses.contains {
            debugLog("参数: \($0)")
            return $0 > 100
        }
        
        let names: Set = ["Sofia", "Camilla", "Martina", "Mateo", "Nicolás"]
        var shorterIndices: [Set<String>.Index] = []
        let tmpZip = zip(names.indices, names)
        for (i, name) in zip(names.indices, names) {
            if name.count <= 5 {
                shorterIndices.append(i)
            }
        }
        for i in shorterIndices {
            print(names[i])
        }
        // Prints "Sofia"
        // Prints "Mateo"
    }
    
    static func testApiMethod() {
        
        //        if #available(iOS 15.0, *) {
        //            Task {
        //                await processWeather()
        //                debugLog("异步任务结束了吗")
        //            }
        //        } else {
        //            // Fallback on earlier versions
        //        }
        
        //============================================================
        
        //     for _ in 0...100 {
        //         DispatchQueue.global().async {
        //             self.testJSONEncoder()
        //         }
        //     }
        
        //        let reslut = isValidEmail(email: "123452")
        //        debugLog("正则表达式验证: \(reslut)")
    }
    
    /// 系统高阶函数
    @objc static func testHighFunctionApi() {
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
            // Int($0)! % 2 == 0 解包失败时崩溃
            Int($0).map { $0 % 2 } == 0
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
    
    //MARK: iOS15新特性Api
    
    func setScore1(to score: Int) {
        print("Setting score to \(score)")
    }
    
    func setScore2(@Clamped(range: 0...100) to score: Int) {
        print("Setting score to \(score)")
    }
    
    // 省略复杂的网络代码，这里我们直接用100000条记录来代替
    @available(iOS 15.0.0, *)
    func fetchWeatherHistory() async -> [Double] {
        debugLog("===========222=============")
        return (1...100_000).map { _ in Double.random(in: -10...30) }
    }
    
    // 对数组求和然后求平均值
    @available(iOS 15.0.0, *)
    func calculateAverageTemperature(for records: [Double]) async -> Double {
        debugLog("===========444=============")
        let total = records.reduce(0, +)
        let average = total / Double(records.count)
        return average
    }
    
    // 省略网络代码，发送回服务器
    @available(iOS 15.0.0, *)
    func upload(result: Double) async -> String {
        debugLog("===========666=============")
        return "OK"
    }
    
    @available(iOS 15.0.0, *)
    @objc func processWeather() async {
        debugLog("===========111=============")
        let records = await fetchWeatherHistory()
        debugLog("===========333=============")
        let average = await calculateAverageTemperature(for: records)
        debugLog("===========555=============")
        let response = await upload(result: average)
        debugLog("===========777=============")
        debugLog("Server response: \(response)")
    }
    
    @available(iOS 15.0.0, *)
    func printMessage() async {
        let string = await withTaskGroup(of: String.self) { group -> String in
            group.async { "Hello" }
            group.async { "From" }
            group.async { "A" }
            group.async { "Task" }
            group.async { "Group" }
            var collected = [String]()
            for await value in group {
                collected.append(value)
            }
            return collected.joined(separator: " ")
        }
        print(string)
    }
    
    
    func printGreeting(to: String) -> String {
        print("In printGreeting()")
        return "Hello, \(to)"
    }
    
    func lazyTest() {
        print("Before lazy")
        lazy var greeting = printGreeting(to: "Paul")
        print("After lazy")
        print(greeting)
    }
    
    func testJSONEncoder() {
        let student = StudentModel()
        do {
            let result = try JSONEncoder().encode(student)
            let jsonString = String(decoding: result, as: UTF8.self)
            print(jsonString)
        } catch {
            print("Encoding error: \(error.localizedDescription)")
        }
    }
    
    func isValidEmail(email: String) -> Bool {
        var result = true
        let regex = try? NSRegularExpression(pattern: "^[0-9]{5}$", options: [.caseInsensitive])
        if let regex = regex  {
            result = (regex.firstMatch(in: email, options: [], range: NSRange(location: 0, length: email.count)) != nil)
        }
        return result
    }
    
    func zf_evaluatePredicate(regex: String?, text: String) throws -> Bool {
        guard let regex = regex else { return false }
        var result = false
        
        let predicate = try? NSPredicate(format: "SELF MATCHES \(regex)")
        if let predicate = predicate {
            result = predicate.evaluate(with: text)
        }
        //        do {
        //            let predicate = try getPredicate(regex: regex)
        //            result = predicate.evaluate(with: text)
        //        } catch let error{
        //            print("error:\(error)")
        //        }
        return result
    }
    
    //有抛出错误的方法
    func getPredicate(regex: String) throws -> NSPredicate {
        return NSPredicate(format: "SELF MATCHES \(regex)")
    }
    
}
