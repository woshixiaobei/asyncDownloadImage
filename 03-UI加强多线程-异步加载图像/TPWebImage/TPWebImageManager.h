//
//  TPWebImageManager.h
//  03-UI加强多线程-异步加载图像
//
//  Created by 小贝 on 16/5/30.
//  Copyright © 2016年 小贝. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  设置图片管理器,负责所有的图像的异步下载和缓存,是一个单例
 */
@interface TPWebImageManager : NSObject

/**
 *  全局访问点
 */
+ (instancetype)shareManager;

@end
