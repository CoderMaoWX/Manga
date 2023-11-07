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
//盒子布局框架:https://yogalayout.com/docs
import YogaKit

class TestViewController: BaseVC {
    
    var requestTask: WXDataRequest? = nil;

    override func viewDidLoad() {
        super.viewDidLoad()
        configRequest()
        configNavgationView()
//        testIOS15Api()
//        testYogaKit()
    }
    
    @IBOutlet weak var testView: UIView?
    @IBAction func testVisibilty(switchbutton: UISwitch) {

        let viewHeight: CGFloat = switchbutton.isOn ? 100 : 0.0
        self.testView?.visiblity(gone: !switchbutton.isOn, dimension: viewHeight)

        // set visibility for width constraint
        //let viewWidth:CGFloat = switchbutton.isOn ? 300 : 0.0
        //self.testView?.visiblity(gone: !switchbutton.isOn, dimension: viewWidth, attribute: .width)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        test_iOS16_Swift_v5_7()
    }
    
    func test_iOS16_Swift_v5_7() {
        
        // MARK: Hide
        let message = "the cat sat on the mat"
        if #available(iOS 16.0, *) {
            debugLog(message.ranges(of: "at"))
            debugLog(message.replacing("cat", with: "dog"))
            debugLog(message.trimmingPrefix("the "))
            
            debugLog("====================")
            
            debugLog(message.ranges(of: /[a-z]at/))
            debugLog(message.replacing(/[a-m]at/, with: "dog"))
            debugLog(message.trimmingPrefix(/The/.ignoresCase()))
            
            // MARK: Show
            do {
                let atSearch = try Regex("[a-z]at")
                print(message.ranges(of: atSearch))
            } catch {
                print("Failed to create regex")
            }
            
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    func drawLotto1<T: Sequence>(from options: T, count: Int = 7) -> [T.Element] {
        Array(options.shuffled().prefix(count))
    }
    
    func testYogaKit() {
//        self.view.configureLayout{ (layout) in
//          layout.isEnabled = true
//          layout.width = YGValue(self.view.bounds.size.width)
//          layout.height = YGValue(self.view.bounds.size.height)
//          layout.alignItems = .center
//          layout.justifyContent = .center
//        }
        
        let contentView = UIView()
        contentView.backgroundColor = .lightGray
        view.addSubview(contentView)
        contentView.configureLayout { (layout) in
          layout.isEnabled = true
            layout.flexDirection = .row
          layout.width = 320
          layout.height = 80
          layout.marginTop = 40
          layout.marginLeft = 10
          layout.padding = 10
        }
        
        let child1 = UIView()
        child1.backgroundColor = .red
        contentView.addSubview(child1)
        child1.configureLayout{ (layout)  in
          layout.isEnabled = true
          layout.width = 80
          layout.marginRight = 10
        }
        
        let child2 = UIView()
        child2.backgroundColor = .blue
        contentView.addSubview(child2)
        child2.configureLayout{ (layout)  in
          layout.isEnabled = true
          layout.width = 80
          layout.flexGrow = 1
          layout.height = 20
          layout.alignSelf = .center
        }
        
        contentView.yoga.applyLayout(preservingOrigin: true)
//        self.view.yoga.applyLayout(preservingOrigin: true)
        
    }
    
    ///导航栏事件
    func configNavgationView() {
        navigationItem.title = "测试标题"
        view.addLineTo(position: .top, thinSize: 1)
        setNavBarLeftItem(info: [UIImage(named:"acg_like")!, "Message"]) { button in
            if button.tag == 1 {
                self.testUploadFile()
            } else {
                ApiClass.studyApi()
                var str = "ABCDEFGH"
                let start = str.index(str.startIndex, offsetBy: 2)
                let end = str.index(str.endIndex, offsetBy: -1)
                let range = start...end
                str.removeSubrange(range)
                debugLog("判断空字符串", str)
                
            }
        }
        setNavBarRightItem(info: ["Bag", UIImage(named: "selected_on")!]) { button in
            //showAlertControllerToast(message: "右侧按钮: \(button)")
            if button.tag == 0 {
                self.setValue("123", forKey: "name")
                OpenWXDeeplink(url: "https://www.free-api.com/doc/383", title: "Baidu")
            } else {
                let videoVC = ShowVideoVC()
                self.navigationController?.pushViewController(videoVC, animated: true)
            }
        }
    }
    
    func configRequest() {
        //测试设置全局: 请求状态/解析模型
        WXRequestConfig.shared.successStatusMap = (key: "returnCode",  value: "SUCCESS")
        WXRequestConfig.shared.messageTipKeyAndFailInfo = (tipKey: "msg", defaultTip: "程序小哥开小差,请稍后再试!")
        WXRequestConfig.shared.uploadRequestLogTuple = (url: "http://10.8.41.162:8090/pullLogcat", catchTag: nil)
        WXRequestConfig.shared.forbidProxyCaught = true
        WXRequestConfig.shared.isDistributionOnlineRelease = true
        WXRequestConfig.shared.urlResponseLogTuple = (printf: true, hostTitle: "开发环境")
        WXRequestConfig.shared.requestHUDCalss = WXLoadingHUD.self
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
        api.requestSerializer = .EncodingFormURL
        api.timeOut = 40
        api.loadingSuperView = view
        api.successStatusMap = (key: "retcode", value: "0")
        api.parseModelMap = (parseKey: "data", modelType: WeiboModel.self)
        api.startRequest { [weak self] responseModel in
            self?.textView.text = responseModel.responseDict?.debugDescription.unicodeToString
            showToastText(responseModel.responseMsg)
        }
    }

    func testBatchData() {
        let url0 = "http://123.207.32.32:8000/home/multidata"
        let api0 = WXRequestApi(url0, method: .get, parameters: nil)
        api0.successStatusMap = (key: "returnCode",  value: "SUCCESS")
        api0.requestSerializer = .EncodingFormURL
//        api0.autoCacheResponse = true
        
        
        let url1 = "https://httpbin.org/delay/5"
        //let para0: [String : Any] = ["name" : "张三"]
        let api1 = WXRequestApi(url1, method: .get)
        api1.requestSerializer = .EncodingFormURL
//        api1.autoCacheResponse = true
        
        
        let url3 = "https://httpbin.org/post"
        let api3 = WXRequestApi(url3, method: .post)
        api3.requestSerializer = .EncodingFormURL

        
        let api = WXBatchRequestApi(apiArray: [api1, api0, api3], loadingTo: view)
        api.startRequest({ batchApi in
            debugLog("批量请求回调", batchApi.responseDataArray)
        }, waitAllDone: true)
    }
    
    ///测试不发请求,直接返回赋值的 testResponseJson
    func testJsonData() {
        let url = "http://app.u17.com/v3/appV3_3/ios/phone/comic/boutiqueListNew"
		let param: [String : Any] = ["sexType" : 1]

        let api = WXRequestApi(url, method: .get, parameters: param)
        api.requestSerializer = .EncodingFormURL
//        api.debugJsonResponse = "http://10.8.41.162:8090/app/activity/page/detail/92546"  //http(s) URL
//        api.debugJsonResponse = "/Users/xin610582/Desktop/test.json"                      //Desktop json file
//        api.debugJsonResponse = "test.json"                                               //Bundle json file
//        api.debugJsonResponse = ["code" : "1", "data" : ["message" : "测试字典"]]           //Dictionary Object
        api.debugJsonResponse = "{\"code\":\"1\",\"data\":{\"message\":\"测试json\"}}"     //Json String

        api.timeOut = 40
        api.loadingSuperView = view
        api.autoCacheResponse = false
        api.retryWhenFailTuple = (times: 3, delay: 1.0)
        api.successStatusMap = (key: "code", value: "1")
        api.parseModelMap = (parseKey: "data.returnData.comicLists", modelType: ComicListModel.self)

		api.startRequest { [weak self] responseModel in
            self?.textView.text = responseModel.responseDict?.debugDescription.unicodeToString
        }
    }
    
    ///测试上传文件
    func testUploadFile() {
        let image = UIImage(named: "womenPic")!
        let imageData = image.pngData()
        
//        let path = URL(fileURLWithPath: "/Users/luke/Desktop/video.mp4")
//        let imageData = Data.init(base64Encoded: path.absoluteString)
        
        let url = "http://10.8.31.61:8090/uploadImage"
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
        
        url = "https://tucdn.wpon.cn/api-girl/index.php?wpon=302"
        
        url = "https://v.api.aa1.cn/api/api-dy-girl/index.php?aa1=ajdu987hrjfw"
        
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
            
        }.first!.badgeValue = " new "
        
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
        textView.dataDetectorTypes = .link;
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
                //debugLog("\nUIAction点击事件", action)
            }
            let btn = WXTmpView.init(configuration: conf, primaryAction: action)
            btn.addTarget(self, action: #selector(myUIAction), for: .touchUpInside)
            btn.setImage(UIImage(named: "refresh_icon"), for: .normal)
            btn.setTitle("刷新", for: .normal)
            btn.frame = CGRect(x: 100, y: 200, width: 100, height: 100)
            btn.backgroundColor = .groupTableViewBackground
            view.addSubview(btn)
            
            let topView = UIButton(frame: CGRect(x: 30, y: -80, width: 50, height: 60))
            topView.addTarget(self, action: #selector(topViewAction), for: .touchUpInside)
            topView.backgroundColor = .gray
            topView.tag = 2021
            btn.addSubview(topView)
        }
    }
    
    @objc func topViewAction(button: UIButton) {
        debugLog("点击了浮层")
//        button.backgroundColor = .random
    }
    
    @objc func myUIAction(button: UIButton) {
        debugLog("点击了底部按钮")
        button.backgroundColor = .random
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

class WXTmpView: UIButton {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        var tmpView = super.hitTest(point, with: event)
        if tmpView == nil {
            let topView = self.viewWithTag(2021)!
            if topView.frame.contains(point) {
                tmpView = topView
            }
        }
        return tmpView
    }
}
