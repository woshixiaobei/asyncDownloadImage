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


@end
