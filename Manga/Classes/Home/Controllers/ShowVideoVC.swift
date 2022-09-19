//
//  ShowVideoVC.swift
//  iManga
//
//  Created by 610582 on 2022/9/19.
//

import UIKit
import WXNetworkingSwift
import Alamofire
import Photos

class ShowVideoVC: BaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        configNavgationView()
    }
    
    override func initAddSubView() {
        view.addSubview(textLabel)
    }
    
    override func layoutSubView() {
        textLabel.snp.makeConstraints {
            $0.edges.equalTo(UIEdgeInsets.zero)
        }
    }
    
    ///导航栏事件
    func configNavgationView() {
        navigationItem.title = "小视频"
        setNavBarRightItem(info: ["下载视频"]) { [self] button in
//            self.downVideoFile()
            self.downVideoFileBy(downURL: "https://v.api.aa1.cn/api/api-dy-girl/index.php?aa1=ajdu987hrjfw")
        }
    }
    
    ///开始下载视频
    func downVideoFileBy(downURL: String) {
        showLoading(to: view)
        
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        AF.download(downURL, to:destination).response { [self] response in
            hideLoading(from: self.view)
            
            if let fileURL = response.fileURL {
                permissions(videoURL: fileURL)
            } else{
                self.textLabel.text = "下载失败"
                showToastText("下载失败")
            }
        }.downloadProgress { progress in
            debugLog("下载进度: \(progress)")
            self.textLabel.text = progress.debugDescription
        }
    }
    
    ///保存视频到相册
    private func saveVideoToLocal(_ videoURL: URL) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
        }) { (bool, error) in
            if bool {
                showToastText("保存成功")
                DispatchQueue.main.async {
                    self.textLabel.text = "保存成功"
                }
            }else{
                showToastText("保存失败")
                DispatchQueue.main.async {
                    self.textLabel.text = "保存失败"
                }
            }
        }
    }
    
    ///有没有pn写入s权限判断
    private func permissions(videoURL: URL){

        if PHPhotoLibrary.authorizationStatus().rawValue == PHAuthorizationStatus.notDetermined.rawValue {
            ///用户还没做选择
            PHPhotoLibrary.requestAuthorization({ [self] (status) in

                if status.rawValue == PHAuthorizationStatus.authorized.rawValue {
                    saveVideoToLocal(videoURL)
                    
                } else if status == PHAuthorizationStatus.denied ||  status == PHAuthorizationStatus.restricted {
                    self.jumpSystemSetting()
                }
            })
            
        } else if(PHPhotoLibrary.authorizationStatus().rawValue == PHAuthorizationStatus.authorized.rawValue ) {
            //用户同意写入权限
            print(PHPhotoLibrary.authorizationStatus().rawValue)
            saveVideoToLocal(videoURL)
        } else {
            self.jumpSystemSetting()
        }
    }
    
    ///跳转系统设置
    func jumpSystemSetting() {
        let url = URL(string: UIApplication.openSettingsURLString)
        if let url = url, UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:],
                                          completionHandler: {
                    (success) in
                })
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    ///下载视频文件
    func downVideoFile() {
        var url = "https://tucdn.wpon.cn/api-girl/index.php?wpon=302"
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
    
    lazy var textLabel: UILabel = {
        let lb = UILabel()
        lb.backgroundColor = .white
        lb.font = .systemFont(ofSize: 14)
        lb.textColor = .black
        lb.textAlignment = .center
        lb.numberOfLines = 0
        lb.text = "小视频"
        return lb
    }()
}
