[版权所有,转载请注明出处!](http://juanfelix.sinaapp.com)

### 通过Tap事件获取 UIWebView 中的图片

===

##### 需求:

- 通过点击UIWebView，获取相应位置中的图片URL 并浏览。
- 也可自己扩展其他内容，如对webView中的`图片长按保存`或者`长按识别二维码`思路都是一样的

##### 思路：
- 给UIWebView添加Tap手势
- 获取Tap事件的点击坐标，转换为WebView 中得位置偏移量Point
- 给WebView注意本地JS方法，传入Point获取相应的HTML标签元素

##### 注意：
- 为确保我们的添加在UIWebView上的Tap手势会正常执行需添加以下代码：

```

	tapGesture.cancelsTouchesInView = false	

	//MARK: UIGestureDelegate
	func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, 	shouldRecognizeSimultaneouslyWithGestureRecognizer 	otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }    
    
```

- [相关手势介绍可参考该片博文](http://www.cnblogs.com/salam/archive/2013/04/30/iOS_gesture.html)

##### Tap手势事件：
```
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

```

##### 效果图

![image](https://github.com/iFallen/ImageTemp/raw/master/ScreenShots/Blog4/1.png =320x)
![image](https://github.com/iFallen/ImageTemp/raw/master/ScreenShots/Blog4/2.png =320x)

---

[SourceCode](http://)






