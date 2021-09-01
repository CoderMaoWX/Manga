//
//  AppDelegate.swift
//  Manga
//
//  Created by 610582 on 2021/1/29.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //开启网络监听
        networkListen()
        
        //监听文件夹变化
        startMonitorFile()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
        window?.rootViewController = TabBarController()
        window?.makeKeyAndVisible()
        return true
    }
    
    
    //实时监听沙盒文件夹的变化
    fileprivate var sourceTimer: DispatchSourceFileSystemObject!

    fileprivate let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!

    // MARK: - 监听文件夹变化
       func startMonitorFile() {
           let directoryURL = URL(fileURLWithPath: docPath)
           
           let content:[CChar] = directoryURL.path.cString(using: .utf8)!
           let fd =  open(content, O_EVTONLY)
           if fd < 0 {
               debugLog("Unable to open t`he path = \(directoryURL.path)")
               return
           }

           let timer = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fd, eventMask: .write, queue: DispatchQueue.global())
           timer.setEventHandler {[weak self] in
               let event:DispatchSource.FileSystemEvent = timer.data
               switch event {
               
               case .write:
                   debugLog("Document file changed")
               default:
                   debugLog("Document file changed")
               }
               
               DispatchQueue.main.async {
//                   self?.listTb.reloadData()
               }
           }

           timer.setCancelHandler {
               debugLog("destroy timer")
               close(fd)
           }
           
           sourceTimer = timer
           timer.resume()
           
       }
    
}

