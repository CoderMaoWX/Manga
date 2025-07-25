//
//  WebVC.swift
//  Manga
//
//  Created by 610582 on 2021/3/23.
//

import UIKit
import SnapKit
import WebKit

class WebVC: BaseVC {
    fileprivate var webURL: String?
    
    var imageItemArray: [ Any ] = []
    
    convenience init(url: String?) {
        self.init()
        webURL = url
    }
    
    fileprivate lazy var progressView: UIProgressView = {
        let pv = UIProgressView(frame: CGRect.zero)
        pv.trackImage = UIImage(named: "nav_bg")
        pv.progressTintColor = UIColor.orange
        return pv
    }()


    func fetchImgClickEventJs() -> String? {
        if let jsPath = Bundle.main.path(forResource: "ImgAddClickEvent", ofType: "js") {
            if let jsString = try? String(contentsOfFile: jsPath, encoding: .utf8) {
                return jsString
            }
        }
        return nil
    }
    
    fileprivate lazy var webView: WKWebView = {

        let configuration = WKWebViewConfiguration()
        let controller = WKUserContentController()
        configuration.userContentController = controller

        let wb = WKWebView(frame: CGRect.zero, configuration: configuration)
        wb.allowsBackForwardNavigationGestures = true
        wb.backgroundColor = UIColor.white
        wb.scrollView.showsVerticalScrollIndicator = false
        wb.scrollView.showsHorizontalScrollIndicator = false
        wb.navigationDelegate = self
        wb.uiDelegate = self
        return wb
    }()

    ///添加自定义的脚本/
    func addWebViewUserScript() {
        if let jsString = fetchImgClickEventJs() {
            let userScript = WKUserScript(source: jsString, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
            webView.configuration.userContentController.addUserScript(userScript)
            //注册回调监听
            webView.configuration.userContentController.removeScriptMessageHandler(forName: "imageDidClick")
            webView.configuration.userContentController.add(self, name: "imageDidClick")
        }
    }
    
    override func initAddSubView() {
        view.addSubview(webView)
        view.addSubview(progressView)
    }
    
    override func layoutSubView() {
        progressView.snp.makeConstraints{
            $0.leading.top.trailing.equalTo(view)
            $0.height.equalTo(2)
        }
        
        webView.snp.makeConstraints{
            $0.edges.equalTo(UIEdgeInsets.zero)
        }
    }
    
    func configNavgationBar() {
        let image = UIImage(named: "nav_reload")?.withRenderingMode(.alwaysOriginal)
        setNavBarRightItem(info: [image as Any]) { [weak self] _ in
            self?.webView.reload()
        }
    }
    
    @objc func reloadWebView() {
        webView.reload()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configNavgationBar()
        addWebViewUserScript()
        loadWebURL()
    }

    func loadWebURL() {
        if webURL == nil {
            if let htmlPath = Bundle.main.path(forResource: "testWeb", ofType: "html") {
                if let htmlString = try? String(contentsOfFile: htmlPath, encoding: .utf8) {
                    webView.loadHTMLString(htmlString, baseURL: nil)
                }
            }
            return
        }
        guard let webURL = webURL else { return }
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        let request = URLRequest(url: URL(string: webURL)!)
        webView.load(request)
    }
    
    override func goBackAction() {
        if webView.canGoBack {
            webView.goBack()
        } else {
            super.goBackAction()
        }
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
}

//利用UIWebViewDelegate实现截取网页中的图片
extension WebVC: WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.body)

        if message.name == "imageDidClick" {
            if let body = message.body as? Dictionary<String, Any>, let currentURL = body["imgUrl"] as? String {
                navigationController?.pushViewController(PreviewImgVC(previewURL: currentURL), animated: true)
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "estimatedProgress") {
            progressView.isHidden = webView.estimatedProgress >= 1
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
    }
    
    // MARK:- WKNavigationDelegate
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.progress = 0.0
        navigationItem.title = webView.title ?? title
        
//        // 注入JS代码获取图片url和个数
//        webView.evaluateJavaScript("""
//             function getImages(){\
//                 var imgs = document.getElementsByTagName('img');\
//                 var imgScr = '';\
//                 for(var i=0;i<imgs.length;i++){\
//                     if (i == 0){ \
//                        imgScr = imgs[i].src; \
//                     } else {\
//                        imgScr = imgScr +'***'+ imgs[i].src;\
//                     } \
//                 };\
//                 return imgScr;\
//             };
//        """, completionHandler: nil)
//
//        webView.evaluateJavaScript("getImages()") { [weak self] (result, error) in
//            guard error == nil else { return }
//            guard let resultString: String = result as? String else { return }
//
//            // 分割字符串, 放入数组中
//            for (_, num) in resultString.components(separatedBy: "***").enumerated() {
//                self?.imageItemArray.append(num)
//            }
//            debugLog("一共有\((self?.imageItemArray.count)!)张图片")
//        }
//
//        //添加图片点击的回调
//        self.webView.evaluateJavaScript("""
//                function registerImageClickAction(){\
//                    var imgs = document.getElementsByTagName('img');\
//                    for(var i=0;i<imgs.length;i++){\
//                        imgs[i].customIndex = i;\
//                        imgs[i].onclick=function(){\
//                            window.location.href='image-preview-index:'+this.customIndex;\
//                        }\
//                    }\
//                }
//        """, completionHandler: nil)
//
//        webView.evaluateJavaScript("registerImageClickAction();", completionHandler: nil)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        // 点击图片
        let url = navigationAction.request.url
        if url?.scheme == "image-preview-index" {
            //图片点击回调
            let index = Int((url!.absoluteString as NSString).substring(from: "image-preview-index:".count)) ?? 0
            debugLog("点击图片 INDEX = \(index)")
            
            //大图 host:  jp.forum.1kxun.com
            let tapStr = self.imageItemArray[index] as! String
            let tapURL = URL(string: tapStr)
            guard let url = tapURL?.host else {
                decisionHandler(.cancel)
                return
            }
//            guard url == "jp.forum.1kxun.com" else {
//                decisionHandler(.cancel)
//                return
//            }
            debugLog("点击图片 IMAGEPATH =  \(url)")
            navigationController?.pushViewController(PreviewImgVC(previewURL: tapStr), animated: true)
            
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}


class PreviewImgVC: BaseVC {
    
    var previewURL: String = ""
    
    convenience init(previewURL: String) {
        self.init()
        self.previewURL = previewURL
    }
    
    var imgView: UIImageView = {
        let img = UIImageView()
        img.backgroundColor = .black
        img.contentMode = .scaleAspectFit
        return img
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imgView.mg.setImageURL(previewURL)
    }
    
    override func initAddSubView() {
        view.backgroundColor = .black
        view.addSubview(imgView)
    }
    
    override func layoutSubView() {
        imgView.snp.makeConstraints{
            $0.leading.trailing.equalTo(view)
            $0.height.equalTo(500)
            $0.centerY.equalTo(view.snp.centerY)
        }
    }
}
