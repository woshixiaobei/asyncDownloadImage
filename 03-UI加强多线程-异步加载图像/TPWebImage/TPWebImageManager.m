//
//  TPWebImageManager.m
//  03-UI加强多线程-异步加载图像
//
//  Created by 小贝 on 16/5/30.
//  Copyright © 2016年 小贝. All rights reserved.
//

#import "TPWebImageManager.h"

@implementation TPWebImageManager

+ (instancetype)shareManager {

    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
         instance = [[self alloc]init];
    });
    return instance;

}
@end
