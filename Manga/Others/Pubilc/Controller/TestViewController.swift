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

class TestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        fd_prefersNavigationBarHidden = true
//         testAlert()
//        testloadData()
//        testType()
        
        view.addSubview(navgationBarView)
        navgationBarView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view)
            $0.height.equalTo(statusAddNavBarHeight)
        }
        
        navgationBarView.setNavBarLeftItem(info: ["Category", "Message"]) { idx in
            showAlertToast(message: "左侧按钮: \(idx)")
        }
        
//        navgationBarView.setNavBarRightItem(infoArr: ["Bag", "Setting"]) { idx in
//            showAlertToast(message: "右侧按钮: \(idx)")
//        }
    }
    
    lazy var navgationBarView: NavgationBarView = {
        let navgationView = NavgationBarView(nil)
        navgationView.title = "Test"
        navgationView.backgroundColor = .groupTableViewBackground
        return navgationView
    }()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        testloadData()
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
