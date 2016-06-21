//
//  ViewController.swift
//  testKingFisher
//
//  Created by 朱晨 on 16/6/13.
//  Copyright © 2016年 朱晨. All rights reserved.
//

import UIKit
import Kingfisher
class ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    var progressView : UIProgressView!
    var cellTitiles = ["Basic Usage","Custom Config","Custom Cache Doc","Caculate Cache Size And Check If Caches Exist","Clear Cache","Prefech Image"]
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
   
        let downloader = KingfisherManager.sharedManager.downloader
        downloader.downloadTimeout = 20
        KingfisherManager.sharedManager.cache.maxDiskCacheSize = 20 * 1024 * 1024
        KingfisherManager.sharedManager.cache.maxCachePeriodInSecond = 3 * 24 * 60 * 60
        KingfisherManager.sharedManager.cache.maxMemoryCost = 20 * 1024 * 1024
        //此方法没有使用缓存策略，不建议直接使用，属于下载图片的底层api不涉及缓存
//        downloader.downloadImageWithURL(NSURL(string: "http://img2.3lian.com/2014/f2/132/d/1.jpg")!, progressBlock: nil) { (image, error, imageURL, originalData) in
//            if error == nil{
//                self.imageView.image = image
//            }
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
}

extension ViewController:UITableViewDataSource,UITableViewDelegate{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel?.text = "\(cellTitiles[indexPath.row])"
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if  indexPath.row == 0 {
            print("click")
            imageView.kf_showIndicatorWhenLoading = true
            imageView.kf_setImageWithURL(NSURL(string: "http://img2.3lian.com/2014/f2/132/d/1.jpg")!)
        } else if indexPath.row == 1{
            
            progressView = UIProgressView(progressViewStyle: .Default)
            progressView.frame.origin = CGPointMake(0, 100)
            progressView.frame.size = CGSizeMake(self.view.frame.width, 10)
            progressView.tintColor = UIColor.greenColor()
            imageView.addSubview(progressView)
            
            //强制每次下载
            let optionInfo : KingfisherOptionsInfo = [.Transition(ImageTransition.Fade(0.1)),.ForceRefresh]
            imageView.kf_setImageWithURL(NSURL(string: "http://img2.3lian.com/2014/f2/132/d/1.jpg")!, placeholderImage: nil, optionsInfo: optionInfo, progressBlock: { (receivedSize, totalSize) in
//                print(receivedSize/totalSize)
                self.progressView.setProgress(Float(receivedSize)/Float(totalSize), animated: true)
                }, completionHandler:{ (image, error, cacheType, imageURL) in
                    self.progressView.hidden = true
            })
        } else if indexPath.row == 2{
//            自定义缓存文件夹
        let cache = ImageCache(name: "myCache")
            imageView.kf_setImageWithURL(NSURL(string: "http://img2.3lian.com/2014/f2/132/d/1.jpg")!, placeholderImage: nil, optionsInfo: [.TargetCache(cache)], progressBlock: nil, completionHandler: nil)
        
        }else if indexPath.row == 3{
             print("before:")
            
            print("after:")
            
            //只能检测disk cache 是否存在
            if KingfisherManager.sharedManager.cache.cachedImageExistsforURL(NSURL(string: "http://img2.3lian.com/2014/f2/132/d/1.jpg")!){
                print("存在")
            }
            
      let result =  KingfisherManager.sharedManager.cache.isImageCachedForKey("http://img2.3lian.com/2014/f2/132/d/1.jpg")
            if result.cached {
                if let type = result.cacheType {
                    switch type {
                    case .None:
                        print("none")
                    case .Memory:
                        print("memory")
                    case .Disk: 
                        print("Disk")
                    }
                }
            }else{
            
                print("没有缓存")
            }
            
            KingfisherManager.sharedManager.cache.calculateDiskCacheSizeWithCompletionHandler({ (size) in
                print("size : \(size)")
            })
            
        }else if indexPath.row == 4{
            //清除默认缓存文件夹
            KingfisherManager.sharedManager.cache.clearMemoryCache()
            KingfisherManager.sharedManager.cache.clearDiskCache()
            print("clean success")
        }else{
            print("click")
            let prefecher = ImagePrefetcher(urls: [NSURL(string: "http://img2.3lian.com/2014/f2/132/d/1.jpg")!], optionsInfo: nil, progressBlock: nil, completionHandler: { (skippedResources, failedResources, completedResources) in
                print(completedResources)
            })
            prefecher.start()
        }
    }
}
