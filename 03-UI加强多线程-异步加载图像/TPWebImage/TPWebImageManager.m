//
//  TPWebImageManager.m
//  03-UI加强多线程-异步加载图像
//
//  Created by 小贝 on 16/5/30.
//  Copyright © 2016年 小贝. All rights reserved.
//

#import "TPWebImageManager.h"
#import "CZAdditions.h"
#import "TPWebImageDownloadOperation.h"

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

    
       //0.断言
    NSAssert(completion != nil, @"必须传入完成回调");
    
    //1.内存缓存
    UIImage *cacheImage = _imageCache[urlString];
    
    if (cacheImage != nil) {
        NSLog(@"返回内存缓存");
        completion(cacheImage);
    }
    
    //2.沙盒缓存
    NSString *cachePath = [self cachePathWithURLString:urlString];
    cacheImage = [UIImage imageWithContentsOfFile:cachePath];
    if (cacheImage != nil) {
        NSLog(@"返回沙盒缓存");
        //1>设置内存缓存
        [_imageCache setObject:cacheImage forKey:urlString];
        //2>完成回调
        completion(cacheImage);
        return;
    }
    
    //3.下载操作过长,需要通过操作缓存避免重复下载
    if (_operationCache[urlString] != nil) {
        NSLog(@"%@ 正在下载中,稍安勿躁....",urlString);
        return;
    }
    //NSLog(@"准备下载图像");
    
    //4.创建下载单张图像的操作
    TPWebImageDownloadOperation *op = [TPWebImageDownloadOperation downloadOperationWithURLString:urlString cachePath:cachePath];
    
    //设置操作回调
    __weak TPWebImageDownloadOperation *weakOp = op;
    [op setCompletionBlock:^{
        NSLog(@"下载操作完成-%@,%@",[NSThread currentThread],weakOp.downloadImage);
    }];
    
    //添加到队列
    [_downloadQueue addOperation:op];
    //添加到下载操作缓冲池
    [_operationCache setObject:op forKey:urlString];
    
}

- (NSString *)cachePathWithURLString:(NSString *)urlString {
    NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    NSString *imageName = [urlString cz_md5String];
    return [cacheDir stringByAppendingPathComponent:imageName];

}
@end
