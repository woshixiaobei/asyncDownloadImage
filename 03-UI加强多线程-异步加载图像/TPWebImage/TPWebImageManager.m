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

#pragma mark-构造函数
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

#pragma mark-下载方法

//异步执行方法,不能够通过方法的返回值返回结果,只能通过block的参数完成回调

- (void)downloadImageWithURLString:(NSString *)urlString completion:(void(^)( UIImage*))completion {

    //1.模拟异步
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [NSThread sleepForTimeInterval:1.0];
        
        //创建图像
        UIImage *image = [UIImage imageNamed:@"user_default"];
        
        //在主线程上更新UI
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"执行完成回调");
            completion(image);
        });
    });
    NSLog(@"come here");
}

@end
