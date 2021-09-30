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


class TestViewController: UIViewController {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //ApiClass.studyApi()
        
        let tmpA: Int? = 4
        tmpA.map {
            debugLog("===测试数据: \($0)")
        }
        
        let tmpArray: [Int]? = [1, 2, 5, 678, 2212]
        
        let tmpResult: [Int]? = tmpArray?.map({
            let tmp = $0
            debugLog("遍历数据: \(tmp)")
            return $0
        })
        debugLog("遍历结果: \(String(describing: tmpResult))")
        
        testDownFile()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        fd_prefersNavigationBarHidden = true
        //testAlert()
        //testloadData()
        //testType()
        
        configNavgationView()
    }
    
    ///自定义导航栏
    func configNavgationView() {
        view.addSubview(navgationBarView)
        navgationBarView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view)
            $0.height.equalTo(statusAddNavBarHeight)
        }
        
        navgationBarView.setNavBarLeftItem(info: [UIImage(named:"mghome_like_select")!, "Message"]) { idx in
            self.testloadData()
            //showAlertToast(message: "左侧按钮: \(idx)")
        }
        
        navgationBarView.setNavBarRightItem(infoArr: ["Bag", UIImage(named: "ImageSelectedSmallOn")!]) { idx in
            showAlertToast(message: "右侧按钮: \(idx)")
        }
    }
    
    lazy var navgationBarView: NavgationBarView = {
        let navgationView = NavgationBarView(nil)
        navgationView.title = "我是标题"
        return navgationView
    }()

    //MARK: ----- 测试代码 -----
    
    func testloadData2() {
        let url0 = "http://123.207.32.32:8000/home/multidata"
        let api0 = WXRequestApi(url0, method: .get, parameters: nil)
        api0.successStatusMap = (key: "returnCode",  value: "SUCCESS")
//        api0.autoCacheResponse = true
        
        
        let url1 = "https://httpbin.org/delay/5"
        //let para0: [String : Any] = ["name" : "张三"]
        let api1 = WXRequestApi(url1, method: .get)
//        api1.autoCacheResponse = true
        
        
        let api = WXBatchRequestApi(requestArray: [api0, api1] )
        api.startRequest({ batchApi in
            debugLog("批量请求回调", batchApi.responseDataArray)
        }, waitAllDone: true)
        
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
        let url = "http://app.u17.com/v3/appV3_3/ios/phone/comic/boutiqueListNew"
		let param: [String : Any] = ["sexType" : 1]

        let api = WXRequestApi(url, method: .get, parameters: param)
//        api.testResponseJson =
//"""
//		{"data":{"message":"成功","stateCode":1,"returnData":{"galleryItems":[],"comicLists":[{"comics":[{"subTitle":"少年 搞笑","short_description":"突破次元壁的漫画！","is_vip":4,"cornerInfo":"190","comicId":181616,"author_name":"壁水羽","cover":"https://cover-oss.u17i.com/2021/07/12647_1625125865_1za73F2a4fD1.sbig.jpg","description":"漫画角色发现自己生活在一个漫画的笼子里，于是奋起反抗作者，面对角色的不配合，作者不得已要不断更改题材，恐怖，魔幻，励志轮番上阵，主角们要一一面对，全力通关","name":"笼中人","tags":["少年","搞笑"]}],"comicType":6,"sortId":"86","newTitleIconUrl":"https://image.mylife.u17t.com/2017/07/10/1499657929_N7oo9pPOhaYH.png","argType":3,"argValue":8,"titleIconUrl":"https://image.mylife.u17t.com/2017/08/29/1503986106_7TY5gK000yjZ.png","itemTitle":"强力推荐作品","description":"更多","canedit":0,"argName":"topic"}],"textItems":[],"editTime":"0"}},"code":1}
//"""

        api.timeOut = 40
        api.loadingSuperView = view
        api.autoCacheResponse = false
        api.retryWhenFailTuple = (times: 3, delay: 1.0)
        api.successStatusMap = (key: "code", value: "1")
        api.parseModelMap = (parseKey: "data.returnData.comicLists", modelType: ComicListModel.self)

		api.startRequest { responseModel in
			self.view.backgroundColor = .groupTableViewBackground
            if let rspData = responseModel.responseObject as? Data {
                if let image = UIImage(data: rspData) {
                    self.view.backgroundColor = .init(patternImage: image)
                }
            }
			debugLog(" ==== 测试接口请求完成 ======")
        }
    }
    
    ///测试上传文件
    func testUploadFile() {
        let image = UIImage(named: "yaofan")!
        let imageData = image.pngData()
        
        let url = "http://10.8.31.5:8090/uploadImage  "
        let param = [
            "appName" : "TEST",
            "platform" : "iOS",
            "version" : "7.3.3",
        ]
        let api = WXRequestApi(url, method: .post, parameters: param)
        api.uploadFileDataArr = [imageData!]
        api.fileProgressBlock = { progress in
            debugLog("上传文件进度 \(progress.completedUnitCount)%")
        }
        api.timeOut = 100
        api.loadingSuperView = view
        api.retryWhenFailTuple = (times: 3, delay: 3.0)
        //api.successStatusMap = (key: "code", value: "1")

        api.uploadFile { responseModel in
            if let rspData = responseModel.responseObject as? Data {
                if let image = UIImage(data: rspData) {
                    self.view.backgroundColor = .init(patternImage: image)
                }
            }
            debugLog(" ==== 测试上传文件请求完成 ======")
        }
    }
    
    ///测试下载文件
    func testDownFile() {
        //let url = "http://i.gtimg.cn/qqshow/admindata/comdata/vipThemeNew_item_2135/2135_i_4_7_i_1.zip"
        let url = "https://picsum.photos/200/300?random=1"
        let api = WXRequestApi(url, method: .get, parameters: nil)
        api.fileProgressBlock = { progress in
            debugLog("下载文件进度 \(progress.completedUnitCount)%")
        }
        api.loadingSuperView = view
        api.retryWhenFailTuple = (times: 3, delay: 3.0)
        //api.successStatusMap = (key: "code", value: "1")

        api.downloadFile { responseModel in
            if let rspData = responseModel.responseObject as? Data {
                if let image = UIImage(data: rspData) {
                    self.view.backgroundColor = .init(patternImage: image)
                }
            }
            debugLog(" ==== 测试下载文件请求完成 ======")
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
//        var parseModelMap: [String : AnyClass]? = nil
//        parseModelMap = ["name" : TestViewController.self]
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
