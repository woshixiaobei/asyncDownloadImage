//
//  TPWebImageManager.m
//  03-UI加强多线程-异步加载图像
//
//  Created by 小贝 on 16/5/30.
//  Copyright © 2016年 小贝. All rights reserved.
//

#import "TPWebImageManager.h"

@interface TPWebImageManager()

/**
 *  下载队列
 */
@property (nonatomic, strong) NSOperationQueue *downloadQueue;
/**
 *  图像缓冲池
 */
@property (nonatomic, strong) NSMutableDictionary *imageCache;
/**
 *  操作缓冲池
 */
@property (nonatomic, strong) NSMutableDictionary *operationCache;

@end
@implementation TPWebImageManager

+ (instancetype)shareManager {

    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
         instance = [[self alloc]init];
    });
    return instance;

}


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        //初始化队列与缓存
        _downloadQueue = [[NSOperationQueue alloc]init];
        
  
        _imageCache = [NSMutableDictionary dictionary];
        
   
        _operationCache = [NSMutableDictionary dictionary];
    }
    return self;
}
@end
