//
//  ViewController.swift
//  HShowWebImage
//
//  Created by JuanFelix on 1/19/16.
//  Copyright © 2016 SKKJ-JuanFelix. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UIWebViewDelegate,UIGestureRecognizerDelegate {

    @IBOutlet var webView: UIWebView!
    
    var activityIndicator:UIActivityIndicatorView!
    var maskView:UIView!
    var imageView:UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        webView.loadRequest(NSURLRequest(URL: NSURL(string: "http://mp.weixin.qq.com/s?__biz=MzAwMDYxNTMyMg==&mid=207860969&idx=1&sn=70aabac86b9bb127b399507f9988e4df&scene=4#wechat_redirect")!))
        let tapActionCheck = UITapGestureRecognizer(target: self, action: "touchOnWebViewRecognizedForWeb:")
        tapActionCheck.delegate = self
        tapActionCheck.cancelsTouchesInView = false//
        
        webView.addGestureRecognizer(tapActionCheck)
        
        imageScanInit()
    }
    
    //MARK: tapActionCheck
    func touchOnWebViewRecognizedForWeb(gestureRecognizer: UITapGestureRecognizer) {
        var point = gestureRecognizer.locationInView(webView)
        // convert point from view to HTML coordinate system
        let viewSize = webView.frame.size
        let windowSize = webView.windowSize()
        
        let f = windowSize.width / viewSize.width;
        if (Double(UIDevice.currentDevice().systemVersion) >= 5.0) {
            point.x = point.x * f
            point.y = point.y * f
        } else {
            // On iOS 4 and previous, document.elementFromPoint is not taking
            // offset into account, we have to handle it
            let offset = webView.scrollOffset()
            point.x = point.x * f + offset.x
            point.y = point.y * f + offset.y
        }
        
        let path = NSBundle.mainBundle().pathForResource("JSTools", ofType: "js")
        do{
            let jsCode = try NSString(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
            webView.stringByEvaluatingJavaScriptFromString(jsCode as String)
            let tags = webView.stringByEvaluatingJavaScriptFromString(String(format: "getHTMLElementsAtPoint(%i,%i);", Int(point.x),Int(point.y)))//奇葩的Swift 不强转Int 得到的居然是0
            let tagsSRC = webView.stringByEvaluatingJavaScriptFromString(String(format: "getLinkSRCAtPoint(%i,%i);", Int(point.x),Int(point.y)))
            print("src:\(tags)")
            print("src:\(tagsSRC)")
            if tags?.rangeOfString(",IMG,") != nil{
                if let imgurl = tagsSRC{
                    print("find it:\(imgurl)")
                    self.view.bringSubviewToFront(activityIndicator)
                    activityIndicator.startAnimating()
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                        let data = NSData(contentsOfURL: NSURL(string: imgurl)!)
                        if let image = UIImage(data: data!){
                            dispatch_async(dispatch_get_main_queue(), { [unowned self]() -> Void in
                                self.activityIndicator.stopAnimating()
                                self.showImageView(image)
                            })
                        }else{
                            self.activityIndicator.stopAnimating()
                        }
                    })
                }
            }
        }catch let error as NSError{
            print("Get JSTools Error.\(error.description),\(error.userInfo)")
        }
    }
    
    //MARK: showImage
    func imageScanInit(){
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicator.center = self.view.center
        maskView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        maskView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: maskView.frame.size.width - 40, height: 0))
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.clearColor()
        imageView.contentMode = .ScaleAspectFit
        imageView.center = self.view.center
        
        maskView.alpha = 0.0
        maskView.hidden = true
        
        maskView.addSubview(imageView)
        self.view.addSubview(maskView)
        self.view.addSubview(activityIndicator)
        
        let tapDismiss = UITapGestureRecognizer(target: self, action: "dismissShowImageView")
        maskView.addGestureRecognizer(tapDismiss)
    }
    
    func showImageView(image:UIImage){
        self.view.bringSubviewToFront(maskView)
        imageView.image = image
        maskView.hidden = false
        UIView.animateWithDuration(0.35, animations: { [unowned self]() -> Void in
            self.maskView.alpha = 1.0
            self.imageView.frame = CGRect(x: 0, y: 0, width: self.maskView.frame.size.width - 40, height: self.maskView.frame.size.height - 100)
            self.imageView.center = self.view.center
            }) { finished in
        }
    }
    
    func dismissShowImageView(){
        UIView.animateWithDuration(0.35, animations: { [unowned self]() -> Void in
            self.maskView.alpha = 0.0
            self.imageView.frame = CGRect(x: 0, y: 0, width: self.maskView.frame.size.width - 40, height: 0)
            self.imageView.center = self.view.center
            }) { finished in
                self.maskView.hidden = true
        }
    }
    
    //MARK: UIGestureDelegate
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

