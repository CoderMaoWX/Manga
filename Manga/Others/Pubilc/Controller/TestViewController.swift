//
//  TestViewController.swift
//  Manga
//
//  Created by 610582 on 2021/8/23.
//
//  测试类

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



class TestViewController: UIViewController {
    
    func testType() {
        //let dType: ComicListModel.Type = ComicListModel.self
        
//        let myBook = Book()
//        let person = ZhangSan<Book>()
//
//        let something1 = person.buySome(number: type(of: myBook))
//        let something2 = person.sallSome(number: 10)
//        something2
//        person.book
        
        var parseKeyPathMap: [String : AnyClass]? = nil
        parseKeyPathMap = ["name" : TestViewController.self]
//        parseKeyPathMap
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        debugLog(self)
        debugLog(type(of: self))
        debugLog(TestViewController.Type.self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
          //testAlert()
        testloadData2()
//        testType()
    }
    
    func testloadData() {
        WXNetworkConfig.shared.showRequestLaoding = true
        
        let url = "http://app.u17.com/v3/appV3_3/ios/phone/comic/boutiqueListNew"
        let param: [String : Any] = ["sexType" : 1]
        
        let api = WXRequestApi(url, method: .get, parameters: param)
        api.retryCountWhenFail = 3
        api.successKeyCodeMap = ["code" : 1]
        api.parseKeyPathMap = ["data.returnData.comicLists" : ComicListModel.self]
        
        api.startRequest { responseModel in
            debugLog(responseModel);
//            responseModel.parseKeyPathModel
        }
    }
    
    func testloadData2() {
        let url0 = "http://app.u17.com/v3/appV3_3/ios/phone/comic/boutiqueListNew"
        let para0: [String : Any] = ["sexType" : 1]
        let api0 = WXRequestApi(url0, method: .get, parameters: para0)
        
        
        let url1 = "http://123.207.32.32:8000/home/multidata"
        let api1 = WXRequestApi(url1, method: .get)
        
        
        let api = WXBatchRequestApi(requestArray: [api0, api1] )
        api.startRequest { batchApi in
            debugLog("批量请求", batchApi.responseDataArray);
        }
    }
    
    //MARK: ----- 测试代码 -----
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
