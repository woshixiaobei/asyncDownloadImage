//
//  TPWebImageDownloadOperation.m
//  03-UI加强多线程-异步加载图像
//
//  Created by 小贝 on 16/5/30.
//  Copyright © 2016年 小贝. All rights reserved.
//

#import "TPWebImageDownloadOperation.h"

@interface TPWebImageDownloadOperation()
/**
 *  图像下载URL字符串
 */
@property (nonatomic, strong) NSString *urlString;
/**
 *  图像保存的缓存路径
 */
@property (nonatomic, strong) NSString *cachePath;

@end
@implementation TPWebImageDownloadOperation

+ (instancetype)downloadOperationWithURLString:(NSString *)urlString cachePath:(NSString *)cachePath {
    
    TPWebImageDownloadOperation *op = [[self alloc]init];
    
    //保存属性
    op.urlString = urlString;
    op.cachePath = cachePath;
    return op;

}

/**
 *  自定义操作入口,如果是自定义,会重写这个方法
 */

- (void)main {
    @autoreleasepool {
        NSLog(@"准备下载图像%@,%@",[NSThread currentThread],_urlString);
        [NSThread sleepForTimeInterval:1.0];
        
        NSURL *url = [NSURL URLWithString:_urlString];
        //下载前判断操作是否被取消
        if (self.isCancelled) {
            NSLog(@"下载前被取消");
            return;
        }
        
        NSData *data = [NSData dataWithContentsOfURL:url];
        //在下载之后判断操作是否被取消
        if (self.isCancelled) {
            NSLog(@"下载之后被取消,直接返回,不回调");
            return;
        }
        //判断二进制数据是否获得成功
        if (data != nil) {
            //使用成员变量记录下载完成的图像
            _downloadImage = [UIImage imageWithData:data];
            
            [data writeToFile:_cachePath atomically:YES];
            NSLog(@"%@保存成功 ",_cachePath);
        }
    }
    
    
}
@end
