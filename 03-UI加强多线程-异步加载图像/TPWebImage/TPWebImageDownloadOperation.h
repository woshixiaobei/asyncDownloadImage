//
//  TPWebImageDownloadOperation.h
//  03-UI加强多线程-异步加载图像
//
//  Created by 小贝 on 16/5/30.
//  Copyright © 2016年 小贝. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 *  负责单个网络的图像下载操作,如果下载成功,写入沙盒
 */
@interface TPWebImageDownloadOperation : NSOperation

/**
 *  创建一个下载操作,下载URLString指定图片,下载成功后,写入沙盒
 */
+ (instancetype)downloadOperationWithURLString:(NSString *)urlString cachePath:(NSString *)cachePath;

@property (nonatomic, strong, readonly)UIImage *downloadImage;
@end
