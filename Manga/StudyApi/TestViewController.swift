//
//  TestViewController.swift
//  Manga
//
//  Created by 610582 on 2021/8/23.
//
//  测试类

import UIKit
import Alamofire
import SnapKit
import FDFullscreenPopGesture

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

class TestViewController: UIViewController {

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


	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

		ApiClass.studyApi()

//		if #available(iOS 15.0, *) {
//			Task {
//				await processWeather()
//
//				debugLog("异步任务结束了吗")
//			}
//		} else {
//			// Fallback on earlier versions
//		}


//============================================================


//	 for _ in 0...100 {
//		 DispatchQueue.global().async {
//			 self.testJSONEncoder()
//		 }
//	 }

//		let reslut = isValidEmail(email: "123452")
//		debugLog("正则表达式验证: \(reslut)")
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


    override func viewDidLoad() {
        super.viewDidLoad()

//		let label = UILabel()
//		label.text = "测试label"
//		label.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
//		label
//#if DEBUG
//	.backgroundColor = .red
//#else
//	.backgroundColor = .blue
//#endif
//	view.addSubview(label)


        fd_prefersNavigationBarHidden = true
//         testAlert()
//        testloadData()
//        testType()
        
        view.addSubview(navgationBarView)
        navgationBarView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view)
            $0.height.equalTo(statusAddNavBarHeight)
        }
        
        navgationBarView.setNavBarLeftItem(info: [UIImage(named:"mghome_like_select")!, "Message"]) { idx in
            showAlertToast(message: "左侧按钮: \(idx)")

			()
        }
        
        navgationBarView.setNavBarRightItem(infoArr: ["Bag", UIImage(named: "ImageSelectedSmallOn")!]) { idx in
            showAlertToast(message: "右侧按钮: \(idx)")
        }
    }
    
    lazy var navgationBarView: NavgationBarView = {
        let navgationView = NavgationBarView(nil)
        navgationView.backgroundColor = .groupTableViewBackground
        navgationView.title = "我是标题"
        return navgationView
    }()


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
			//		do {
			//			let predicate = try getPredicate(regex: regex)
			//			result = predicate.evaluate(with: text)
			//		} catch let error{
			//			print("error:\(error)")
			//		}
		return result
	}

		//有抛出错误的方法
	func getPredicate(regex: String) throws -> NSPredicate {
		return NSPredicate(format: "SELF MATCHES \(regex)")
	}

    //MARK: ----- 测试代码 -----
    
    func testloadData2() {
        let url0 = "http://123.207.32.32:8000/home/multidata"
        let api0 = WXRequestApi(url0, method: .get, parameters: nil)
        api0.successKeyValueMap = ["returnCode" : "SUCCESS"]
        api0.autoCacheResponse = true
        
        
        let url1 = "https://httpbin.org/delay/5"
        //let para0: [String : Any] = ["name" : "张三"]
        let api1 = WXRequestApi(url1, method: .get)
        api1.autoCacheResponse = true
        
        
        let api = WXBatchRequestApi(requestArray: [api0, api1] )
        api.startRequest({ batchApi in
            debugLog("批量请求回调", batchApi.responseDataArray)
        }, waitAllDone: false)
        
    }
    
    func testAFMethod() {
        let url = "https://httpbin.org/image"
        AF.request(url,
                   method: .get,
                   parameters: nil,
                   headers: ["accept" : "image/webp"]).responseJSON { response in
                    switch response.result {
                    case .success(let json):
                        debugLog(json)
                    case .failure(let error):
                        debugLog(error)
                    }
                   }
    }
    
    func testloadData() {
        WXNetworkConfig.shared.showRequestLaoding = true
        
        let url = "http://app.u17.com/v3/appV3_3/ios/phone/comic/boutiqueListNew"
        let param: [String : Any] = ["sexType" : 1]
        
        let api = WXRequestApi(url, method: .get, parameters: param)
        api.loadingSuperView = view
        api.retryCountWhenFail = 3
        api.successKeyValueMap = ["code" : "1"]
        api.parseKeyPathMap = ["data.returnData.comicLists" : ComicListModel.self]
        
        api.startRequest { responseModel in
            debugLog(responseModel);
//            responseModel.parseKeyPathModel
        }
    }
    
    func testType() {
    //        debugLog(self)
    //        debugLog(type(of: self))
    //        debugLog(TestViewController.Type.self)
        
        //let dType: ComicListModel.Type = ComicListModel.self
//        let myBook = Book()
//        let person = ZhangSan<Book>()
//        let something1 = person.buySome(number: type(of: myBook))
//        let something2 = person.sallSome(number: 10)
//        something2
//        person.book
//        var parseKeyPathMap: [String : AnyClass]? = nil
//        parseKeyPathMap = ["name" : TestViewController.self]
    }
    
    func testAlert() {
        setNavBarLeftItem(info: ["测试"]) { _ in
            hideLoading(from: self.view)
            showAlertToast(message: "休息一下,马上回来,休息一下,马上回来")
            
        }.first!.redDotValue = "18"
        
        let img1 = UIImage(named: "search_keyword_refresh")!
        let img2 = UIImage(named: "search_history_delete")!
        setNavBarRightItem(infoArr: [img1, img2] ) { idx in
            
            showAlertMultiple(title: "请闭上眼睛",
                              message: "休息一下,马上回来...",
                              otherBtnTitles: ["去睡觉", "玩游戏"],
                              otherBtnClosure: { idx, title in
                showToastText("\(title)", toView: self.view)
                debugLog("dotValue", idx)
                                
            }, cancelTitle: "好的") {
                showToastText("好的", toView: self.view)
            }
        }
    }

}
