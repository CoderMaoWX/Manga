//
//  TestViewController.swift
//  Manga
//
//  Created by 610582 on 2021/8/23.
//
//  测试类

import UIKit
import SnapKit
import FDFullscreenPopGesture
///判断文件类型
import MobileCoreServices
import WXNetworkingSwift
import SwiftUI

class TestViewController: UIViewController {
    
    var requestTask: WXDataRequest? = nil;

    override func viewDidLoad() {
        super.viewDidLoad()
        WXRequestConfig.shared.uploadRequestLogTuple = (url: "http://10.8.31.5:8090/pullLogcat", catchTag: "mwx678")
        configNavgationView()
    }
    
    ///导航栏事件
    func configNavgationView() {
        navigationItem.title = "测试标题"
        view.addLineTo(position: .top, thinSize: 1)
        setNavBarLeftItem(info: [UIImage(named:"like_select")!, "Message"]) { button in
            self.testGetRequest()
        }
        setNavBarRightItem(info: ["Bag", UIImage(named: "selected_on")!]) { button in
            showAlertControllerToast(message: "右侧按钮: \(button)")
        }
    }
    
    //MARK: ----- 测试请求代码 -----
    
    func testGetRequest() {
        let url = "https://weibointl.api.weibo.cn/portal.php"
        let param: [String : Any] = [
            "ua"    : "iPhone12%2C1_iOS14.2_Weibo_intl._409_wifi",
            "ct"    : "feed",
            "a"     : "search_topic",
            "c"     : "weicoabroad",
            "s"     : "3f16726c",
            "time"  : "1606139954516",
            "lang"  : "en-CN",
            "version" : "409",
        ]
        let api = WXRequestApi(url, method: .get, parameters: param)
        api.timeOut = 40
        api.loadingSuperView = view
        api.successStatusMap = (key: "retcode", value: "0")
        api.parseModelMap = (parseKey: "data", modelType: WeiboModel.self)
        api.startRequest { [weak self] responseModel in
            self?.textView.text = responseModel.responseDict?.debugDescription
        }
    }

    func testBatchData() {
        let url0 = "http://123.207.32.32:8000/home/multidata"
        let api0 = WXRequestApi(url0, method: .get, parameters: nil)
        api0.successStatusMap = (key: "returnCode",  value: "SUCCESS")
        api0.autoCacheResponse = true
        
        
        let url1 = "https://httpbin.org/delay/5"
        //let para0: [String : Any] = ["name" : "张三"]
        let api1 = WXRequestApi(url1, method: .get)
        api1.autoCacheResponse = true
        
        
        let api = WXBatchRequestApi(apiArray: [api0, api1], loadingTo: view)
        api.startRequest({ batchApi in
            debugLog("批量请求回调", batchApi.responseDataArray)
        }, waitAllDone: false)
    }
    
    ///测试不发请求,直接返回赋值的 testResponseJson
    func testJsonData() {
        let url = "http://app.u17.com/v3/appV3_3/ios/phone/comic/boutiqueListNew"
		let param: [String : Any] = ["sexType" : 1]

        let api = WXRequestApi(url, method: .get, parameters: param)
        api.testResponseJson =
"""
		{"data":{"message":"成功","stateCode":1,"returnData":{"galleryItems":[],"comicLists":[{"comics":[{"subTitle":"少年 搞笑","short_description":"突破次元壁的漫画！","is_vip":4,"cornerInfo":"190","comicId":181616,"author_name":"壁水羽","cover":"https://cover-oss.u17i.com/2021/07/12647_1625125865_1za73F2a4fD1.sbig.jpg","description":"漫画角色发现自己生活在一个漫画的笼子里，于是奋起反抗作者，面对角色的不配合，作者不得已要不断更改题材，恐怖，魔幻，励志轮番上阵，主角们要一一面对，全力通关","name":"笼中人","tags":["少年","搞笑"]}],"comicType":6,"sortId":"86","newTitleIconUrl":"https://image.mylife.u17t.com/2017/07/10/1499657929_N7oo9pPOhaYH.png","argType":3,"argValue":8,"titleIconUrl":"https://image.mylife.u17t.com/2017/08/29/1503986106_7TY5gK000yjZ.png","itemTitle":"强力推荐作品","description":"更多","canedit":0,"argName":"topic"}],"textItems":[],"editTime":"0"}},"code":1}
"""

        api.timeOut = 40
        api.loadingSuperView = view
        api.autoCacheResponse = false
        api.retryWhenFailTuple = (times: 3, delay: 1.0)
        api.successStatusMap = (key: "code", value: "1")
        api.parseModelMap = (parseKey: "data.returnData.comicLists", modelType: ComicListModel.self)

		api.startRequest { [weak self] responseModel in
            self?.textView.text = responseModel.responseDict?.debugDescription
        }
    }
    
    ///测试上传文件
    func testUploadFile() {
        let image = UIImage(named: "womenPic")!
        let imageData = image.pngData()
        
//        let path = URL(fileURLWithPath: "/Users/luke/Desktop/video.mp4")
//        let imageData = Data.init(base64Encoded: path.absoluteString)
        
        let url = "http://10.8.31.5:8090/uploadImage"
        let param = [
            "appName" : "TEST",
            "platform" : "iOS",
            "version" : "7.3.3",
        ]
        let api = WXRequestApi(url, method: .post, parameters: param)
        api.loadingSuperView = view
        api.retryWhenFailTuple = (times: 3, delay: 3.0)
        //api.successStatusMap = (key: "code", value: "1")
        
        api.uploadFileDataArr = [imageData!]
        api.uploadConfigDataBlock = { multipartFormData in
            multipartFormData.append(imageData!, withName: "files", fileName: "womenPic.png", mimeType: "image/png")
        }
        api.fileProgressBlock = { progress in
            let total = Float(progress.totalUnitCount)
            let completed = Float(progress.completedUnitCount)
            let percentage = completed / total * 100
            debugLog("上传进度: \(String(format:"%.2f",percentage)) %")
        }
        api.uploadFile { responseModel in
            if let rspData = responseModel.responseObject as? Data {
                if let image = UIImage(data: rspData) {
                    self.view.backgroundColor = .init(patternImage: image)
                }
            }
        }
    }
    
    ///测试下载文件
    func testDownFile() {
        //图片
        var url = "https://picsum.photos/414/896?random=1"
        //视频
        //url = "https://video.yinyuetai.com/d5f84f3e87c14db78bc9b99454e0710c.mp4"
        //压缩包
        url = "http://i.gtimg.cn/qqshow/admindata/comdata/vipThemeNew_item_2018/2018_i_6_0_i_2.zip"
        
        let api = WXRequestApi(url, method: .get, parameters: nil)
        api.loadingSuperView = view
        api.fileProgressBlock = { progress in
            let total = Float(progress.totalUnitCount)
            let completed = Float(progress.completedUnitCount)
            let percentage = completed / total * 100
            debugLog("下载进度: \(String(format:"%.2f",percentage)) %")
        }
        
        api.downloadFile { responseModel in
            if let rspData = responseModel.responseObject as? Data {
                if let image = UIImage(data: rspData) {
                    self.view.backgroundColor = .init(patternImage: image)
                }
                if var mimeType = responseModel.urlResponse?.mimeType {
                    mimeType = mimeType.replacingOccurrences(of: "/", with: ".")
                    let url = URL(fileURLWithPath: "/Users/xin610582/Desktop/" + mimeType, isDirectory: true)
                    try? rspData.write(to: url)
                }
            }
        }
    }
    
    ///https://hangge.com/blog/cache/detail_2216.html
    func getFileName() {
        //测试1
//        let mimeType1 = mimeType(pathExtension: "gif")
//        print(mimeType1)
        
        //测试2
//        let path = Bundle.main.path(forResource: "test1", ofType: "zip")!
        let url = URL(fileURLWithPath: "/Users/luke/Downloads/Jenkins 入门手册.pdf")
        let mimeType2 = mimeType(pathExtension: url.pathExtension)
        print("文件类型: \(mimeType2)")
    }
    
    //根据后缀获取对应的Mime-Type
    func mimeType(pathExtension: String) -> String {
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
                                                           pathExtension as NSString,
                                                           nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?
                .takeRetainedValue() {
                return mimetype as String
            }
        }
        //文件资源类型如果不知道，传万能类型application/octet-stream，服务器会自动解析文件类
        return "application/octet-stream"
    }
    
    func testAlert() {
        setNavBarLeftItem(info: ["测试"]) { _ in
            hideLoading(from: self.view)
            showAlertControllerToast(message: "休息一下,马上回来,休息一下,马上回来")
            
        }.first!.redDotValue = "18"
        
        let img1 = UIImage(named: "refresh_icon")!
        let img2 = UIImage(named: "delete_icon")!
        setNavBarRightItem(info: [img1, img2] ) { idx in
            
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
    
    lazy var textView: UITextView = {
        let textView = UITextView()
        let size = view.bounds.size
        textView.frame = CGRect(x: 0, y: 1, width: size.width, height: size.height)
        textView.textColor = .black
        textView.isEditable = false
        view.addSubview(textView)
        return textView
    }()
    
    func testIOS15Api() {
        if #available(iOS 15.0, *) {
            var conf = UIButton.Configuration.borderedTinted()
            /// 设置图片的摆放（图片在上，则文字在下）
            conf.imagePlacement = .bottom
            /// 设置图片和文字的间距
            conf.imagePadding = 20
            
           let action = UIAction(title: "UIAction", image: UIImage(named: "acg_comment"), identifier: .pasteAndGo, discoverabilityTitle: "discoverabilityTitle", attributes: .destructive, state: .on) { action in
                debugLog("\nUIAction点击事件", action)
            }
            let btn = UIButton.init(configuration: conf, primaryAction: action)
            btn.addTarget(self, action: #selector(myUIAction), for: .touchUpInside)
            btn.setImage(UIImage(named: "refresh_icon"), for: .normal)
            btn.setTitle("刷新", for: .normal)
            btn.frame = CGRect(x: 100, y: 200, width: 100, height: 100)
            btn.backgroundColor = .groupTableViewBackground
            view.addSubview(btn)
        }
    }
    
    @objc func myUIAction(button: UIButton) {
        debugLog("\n点击事件myUIAction", button)
        if #available(iOS 15.0, *) {
            if button.configuration?.imagePlacement == .trailing {
                button.configuration?.imagePlacement = .top
            } else {
                button.configuration?.imagePlacement = .trailing
            }
        } else {
            // Fallback on earlier versions
        }
    }
}
