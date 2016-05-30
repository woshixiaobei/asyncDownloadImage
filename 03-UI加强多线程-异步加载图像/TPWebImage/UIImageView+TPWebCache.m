//
//  UIImageView+TPWebCache.m
//  03-UI加强多线程-异步加载图像
//
//  Created by 小贝 on 16/5/30.
//  Copyright © 2016年 小贝. All rights reserved.
//

#import "UIImageView+TPWebCache.h"
#import "TPWebImageManager.h"
#import <objc/runtime.h>
/**
 *  URLString KEY
 */

const char * tp_URLStringKey = "tp_URLStringKey";

@implementation UIImageView (TPWebCache)

//判断和之前的urlstring是否一致
- (void)tp_setImageWithURLString:(NSString *)urlString {

    if (![urlString isEqualToString:self.tp_urlString] && self.tp_urlString != nil) {
        NSLog(@"取消之前的下载操作%@",self.tp_urlString);
        
        [[TPWebImageManager shareManager] cancelDownloadWithURLString:self.tp_urlString];
        
    }
    //记录新的地址
    self.tp_urlString = urlString;
    //在下载之前,将图像设置为nil
    self.image = nil;
    
    [[TPWebImageManager shareManager] downloadImageWithURLString:urlString completion:^(UIImage * image) {
        //下载完成之后,清空之前保存的URLString
        //????避免再一次进入之后,提示取消下载操作
        self.tp_urlString = nil;
        
        self.image = image;
    }];
}

#pragma mark-重写属性的getter 与 setter 方法

- (void)setTp_urlString:(NSString *)tp_urlString {

    objc_setAssociatedObject(self,tp_URLStringKey,tp_urlString, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
}

- (NSString *)tp_urlString {
    return  objc_getAssociatedObject(self, tp_URLStringKey);



}
@end
