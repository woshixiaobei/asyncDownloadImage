//
//  UIImageView+TPWebCache.h
//  03-UI加强多线程-异步加载图像
//
//  Created by 小贝 on 16/5/30.
//  Copyright © 2016年 小贝. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (TPWebCache)

- (void)tp_setImageWithURLString:(NSString *)urlString;
/**
 *  下载图像的url字符串
 */
@property (nonatomic,copy) NSString *tp_urlString;
@end
