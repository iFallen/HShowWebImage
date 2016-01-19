//
//  UIWebView+WebFrame.m
//  HShowWebImage
//
//  Created by JuanFelix on 1/19/16.
//  Copyright © 2016 SKKJ-JuanFelix. All rights reserved.
//

#import "UIWebView+WebFrame.h"

@implementation UIWebView (WebFrame)

- (CGSize)windowSize {
    CGSize size;
    size.width = [[self stringByEvaluatingJavaScriptFromString:@"window.innerWidth"] integerValue];
    size.height = [[self stringByEvaluatingJavaScriptFromString:@"window.innerHeight"] integerValue];
    return size;
}

- (CGPoint)scrollOffset {
    CGPoint pt;
    pt.x = [[self stringByEvaluatingJavaScriptFromString:@"window.pageXOffset"] integerValue];
    pt.y = [[self stringByEvaluatingJavaScriptFromString:@"window.pageYOffset"] integerValue];
    return pt;
}

@end
